//
//  FGbspatch.cpp
//  FGClient
//
//  Created by 神利 on 14-7-17.
//
//
#include "FGbspatch.h"
#include <bzlib.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <err.h>
#include <unistd.h>
#include <fcntl.h>

static off_t offtin(unsigned char *buf)
{
	off_t y;
    
	y=buf[7]&0x7F;
	y=y*256;y+=buf[6];
	y=y*256;y+=buf[5];
	y=y*256;y+=buf[4];
	y=y*256;y+=buf[3];
	y=y*256;y+=buf[2];
	y=y*256;y+=buf[1];
	y=y*256;y+=buf[0];
    
	if(buf[7]&0x80) y=-y;
    
	return y;
}



bool makeNewfile(const unsigned char*oldfilebuff,unsigned int oldfileSize,const char*p_newfile,const char* p_patchfile)
{
	FILE * f, * cpf, * dpf, * epf;
	BZFILE * cpfbz2, * dpfbz2, * epfbz2;
	int cbz2err, dbz2err, ebz2err;
	int fd;
	ssize_t oldsize,newsize;
	ssize_t bzctrllen,bzdatalen;
	unsigned char header[32],buf[8];
	unsigned char *old, *newfile;
	off_t oldpos,newpos;
	off_t ctrl[3];
	off_t lenread;
	off_t i;
    
    
	/* Open patch file */
	if ((f = fopen(p_patchfile, "r")) == NULL)
    {
		err(1, "fopen(%s)", p_patchfile);
        return false;
    }
    
	/*
     File format:
     0	8	"BSDIFF40"
     8	8	X
     16	8	Y
     24	8	sizeof(newfile)
     32	X	bzip2(control block)
     32+X	Y	bzip2(diff block)
     32+X+Y	???	bzip2(extra block)
     with control block a set of triples (x,y,z) meaning "add x bytes
     from oldfile to x bytes from the diff block; copy y bytes from the
     extra block; seek forwards in oldfile by z bytes".
     */
    
	/* Read header */
	if (fread(header, 1, 32, f) < 32) {
		if (feof(f))
        {
			errx(1, "Corrupt patch\n");
            return false;
        }
		err(1, "fread(%s)", p_patchfile);
        return false;
	}
    
	/* Check for appropriate magic */
	if (memcmp(header, "BSDIFF40", 8) != 0)
    {
		errx(1, "Corrupt patch\n");
        return false;
    }
    
	/* Read lengths from header */
	bzctrllen=offtin(header+8);
	bzdatalen=offtin(header+16);
	newsize=offtin(header+24);
	if((bzctrllen<0) || (bzdatalen<0) || (newsize<0))
    {
		errx(1,"Corrupt patch\n");
        return false;
    }
    
	/* Close patch file and re-open it via libbzip2 at the right places */
	if (fclose(f))
    {
		err(1, "fclose(%s)", p_patchfile);
        return false;
    }
	if ((cpf = fopen(p_patchfile, "r")) == NULL)
    {
		err(1, "fopen(%s)", p_patchfile);
        return false;
    }
	if (fseeko(cpf, 32, SEEK_SET))
    {
		err(1, "fseeko(%s, %lld)", p_patchfile,
		    (long long)32);
        return false;
    }
	if ((cpfbz2 = BZ2_bzReadOpen(&cbz2err, cpf, 0, 0, NULL, 0)) == NULL)
    {
		errx(1, "BZ2_bzReadOpen, bz2err = %d", cbz2err);
        return false;
    }
	if ((dpf = fopen(p_patchfile, "r")) == NULL)
    {
		err(1, "fopen(%s)", p_patchfile);
        return false;
    }
	if (fseeko(dpf, 32 + bzctrllen, SEEK_SET))
    {
		err(1, "fseeko(%s, %lld)", p_patchfile,
		    (long long)(32 + bzctrllen));
        return false;
    }
	if ((dpfbz2 = BZ2_bzReadOpen(&dbz2err, dpf, 0, 0, NULL, 0)) == NULL)
    {
		errx(1, "BZ2_bzReadOpen, bz2err = %d", dbz2err);
        return false;
    }
	if ((epf = fopen(p_patchfile, "r")) == NULL)
    {
		err(1, "fopen(%s)", p_patchfile);
        return false;
    }
	if (fseeko(epf, 32 + bzctrllen + bzdatalen, SEEK_SET))
    {
		err(1, "fseeko(%s, %lld)", p_patchfile,
		    (long long)(32 + bzctrllen + bzdatalen));
        return false;
    }
	if ((epfbz2 = BZ2_bzReadOpen(&ebz2err, epf, 0, 0, NULL, 0)) == NULL)
    {
		errx(1, "BZ2_bzReadOpen, bz2err = %d", ebz2err);
        return false;
    }
//	if(((fd=open(p_oldfile,O_RDONLY,0))<0) ||
//       ((oldsize=lseek(fd,0,SEEK_END))==-1) ||
//       ((old=(unsigned char *)malloc(oldsize+1))==NULL) ||
//       (lseek(fd,0,SEEK_SET)!=0) ||
//       (read(fd,old,oldsize)!=oldsize) ||
//       (close(fd)==-1))
    old=(unsigned char*)oldfilebuff;
    oldsize=oldfileSize;


	if((newfile=(unsigned char *)malloc(newsize+1))==NULL)
    {
        err(1,NULL);
        return false;
    }
	oldpos=0;newpos=0;
	while(newpos<newsize) {
		/* Read control data */
		for(i=0;i<=2;i++) {
			lenread = BZ2_bzRead(&cbz2err, cpfbz2, buf, 8);
			if ((lenread < 8) || ((cbz2err != BZ_OK) &&
                                  (cbz2err != BZ_STREAM_END)))
            {
				errx(1, "Corrupt patch\n");
                return false;
            }
			ctrl[i]=offtin(buf);
		};
        
		/* Sanity-check */
		if(newpos+ctrl[0]>newsize)
        {
			errx(1,"Corrupt patch\n");
            return false;
        }
        
		/* Read diff string */
		lenread = BZ2_bzRead(&dbz2err, dpfbz2, newfile + newpos, ctrl[0]);
		if ((lenread < ctrl[0]) ||
		    ((dbz2err != BZ_OK) && (dbz2err != BZ_STREAM_END)))
        {
			errx(1, "Corrupt patch\n");
            return false;
        }
		/* Add old data to diff string */
		for(i=0;i<ctrl[0];i++)
			if((oldpos+i>=0) && (oldpos+i<oldsize))
				newfile[newpos+i]+=old[oldpos+i];
        
		/* Adjust pointers */
		newpos+=ctrl[0];
		oldpos+=ctrl[0];
        
		/* Sanity-check */
		if(newpos+ctrl[1]>newsize)
        {
			errx(1,"Corrupt patch\n");
            return false;
        }
		/* Read extra string */
		lenread = BZ2_bzRead(&ebz2err, epfbz2, newfile + newpos, ctrl[1]);
		if ((lenread < ctrl[1]) ||
		    ((ebz2err != BZ_OK) && (ebz2err != BZ_STREAM_END)))
        {
			errx(1, "Corrupt patch\n");
            return false;
        }
		/* Adjust pointers */
		newpos+=ctrl[1];
		oldpos+=ctrl[2];
	};
    
	/* Clean up the bzip2 reads */
	BZ2_bzReadClose(&cbz2err, cpfbz2);
	BZ2_bzReadClose(&dbz2err, dpfbz2);
	BZ2_bzReadClose(&ebz2err, epfbz2);
	if (fclose(cpf) || fclose(dpf) || fclose(epf))
    {
		err(1, "fclose(%s)", p_patchfile);
        return false;
    }
	/* Write the new file */
	if(((fd=open(p_newfile,O_CREAT|O_TRUNC|O_WRONLY,0666))<0) ||
       (write(fd,newfile,newsize)!=newsize) || (close(fd)==-1))
    {
		err(1,"%s",p_newfile);
        return false;
    }
	free(newfile);

	return true;
}

bool FGbsPatch(const unsigned char*oldfilebuff,unsigned int oldfileSize,const char*p_newfile,const char* p_patchfile)
{
    return makeNewfile(oldfilebuff,oldfileSize,p_newfile,p_patchfile);
}