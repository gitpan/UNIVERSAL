use ExtUtils::MakeMaker;

WriteMakefile(	NAME	    	=> 'UNIVERSAL',
    	    	VERSION_FROM 	=> 'UNIVERSAL.pm',
		dist	    	=>  {COMPRESS	 => 'gzip -9f',
			    	     SUFFIX	 => 'gz',
			    	     DIST_DEFAULT => 'all tardist',
			    	    },
	     );
