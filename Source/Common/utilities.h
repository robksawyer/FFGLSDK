/*
 *  utilities.h
 *  FFGLPlugins
 *
 *  Created by Edwin de Koning on 12/13/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */
unsigned int is_power_of_2(unsigned int x);
int npot(int n);
#ifdef _WIN32
double round(double r);
#endif

double getTicks();
void init_time(double *t0);
void update_time(double *t, const double t0);

void HSVtoRGB(float h, float s, float v, float* r, float* g, float* b);
