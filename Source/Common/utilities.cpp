/*
 *  utilities.cpp
 *  FFGLPlugins
 *
 *  Created by Edwin de Koning on 12/13/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include <cmath>
#include "utilities.h"
#ifdef _WIN32
#include <Windows.h>
#else
#include <sys/time.h>
#endif
#ifdef __APPLE__	//OS X
#include <Carbon.h>
#endif

#ifdef _WIN32
double round(double r) {
    return (r > 0.0) ? floor(r + 0.5) : ceil(r - 0.5);
}
#endif

double getTicks()
{
	//return 40;
	
	#ifdef _WIN32
	return (double) GetTickCount();
	#else

	Nanoseconds nano = AbsoluteToNanoseconds( UpTime() );
	// if you want that in (floating point) seconds:
	double seconds = ((double) UnsignedWideToUInt64( nano )) * 1e-9;
	return seconds * 1000.0;

	
	#endif

}

unsigned int is_power_of_2(unsigned int x)
{
	return (x != 0) && ((x & (x - 1)) == 0);
}


int npot(int n)
{
	if (is_power_of_2(n)) return n;

	int prevn = n;

	while(n &= n-1)
        prevn = n;
    return prevn * 2;

} 

void HSVtoRGB(float h, float s, float v, float* r, float* g, float* b)
{

  if ( s == 0 )

  {

     *r = v;

     *g = v;

     *b = v;

  } else {

     float var_h = h * 6;

     float var_i = floor( var_h );

	 float var_1 = v * ( 1 - s );

	 float var_2 = v * ( 1 - s * ( var_h - var_i ) );

	 float var_3 = v * ( 1 - s * ( 1 - ( var_h - var_i ) ) );


     if      ( var_i == 0 ) { *r = v     ; *g = var_3 ; *b = var_1; }

     else if ( var_i == 1 ) { *r = var_2 ; *g = v     ; *b = var_1; }

     else if ( var_i == 2 ) { *r = var_1 ; *g = v     ; *b = var_3; }

     else if ( var_i == 3 ) { *r = var_1 ; *g = var_2 ; *b = v;     }

     else if ( var_i == 4 ) { *r = var_3 ; *g = var_1 ; *b = v;     }

     else                   { *r = v     ; *g = var_1 ; *b = var_2; }



  }

}

void init_time(double *t0)
{
#ifdef _WIN32
	//amount of time since plugin init, in seconds (same as SetTime):
		*t0 = double(GetTickCount()/1000);
#else
		timeval time;
		gettimeofday(&time, NULL);
		long millis = (time.tv_sec * 1000) + (time.tv_usec / 1000);
		*t0 = double(millis)/1000.0f;
#endif	
return;
}

void update_time(double *t, const double t0)
{
#ifdef _WIN32
		//amount of time since plugin init, in seconds (same as SetTime):
			*t = double(GetTickCount())/1000.0 - t0;
#else
			timeval time;
			gettimeofday(&time, NULL);
			long millis = (time.tv_sec * 1000) + (time.tv_usec / 1000);
			*t = double(millis)/1000.0f - t0;
#endif	
			return;
}