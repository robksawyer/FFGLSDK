#include "camera.h"
#include "math.h"
#include <iostream>
#include "windows.h"

#define SQR(x) (x*x)

#define NULL_VECTOR F3dVector(0.0f,0.0f,0.0f)

Camera3dVector F3dVector ( GLfloat x, GLfloat y, GLfloat z )
{
	Camera3dVector tmp;
	tmp.x = x;
	tmp.y = y;
	tmp.z = z;
	return tmp;
}

GLfloat GetF3dVectorLength( Camera3dVector * v)
{
	return (GLfloat)(sqrt(SQR(v->x)+SQR(v->y)+SQR(v->z)));
}

Camera3dVector Normalize3dVector( Camera3dVector v)
{
	Camera3dVector res;
	float l = GetF3dVectorLength(&v);
	if (l == 0.0f) return NULL_VECTOR;
	res.x = v.x / l;
	res.y = v.y / l;
	res.z = v.z / l;
	return res;
}

Camera3dVector operator+ (Camera3dVector v, Camera3dVector u)
{
	Camera3dVector res;
	res.x = v.x+u.x;
	res.y = v.y+u.y;
	res.z = v.z+u.z;
	return res;
}
Camera3dVector operator- (Camera3dVector v, Camera3dVector u)
{
	Camera3dVector res;
	res.x = v.x-u.x;
	res.y = v.y-u.y;
	res.z = v.z-u.z;
	return res;
}


Camera3dVector operator* (Camera3dVector v, float r)
{
	Camera3dVector res;
	res.x = v.x*r;
	res.y = v.y*r;
	res.z = v.z*r;
	return res;
}

Camera3dVector CrossProduct (Camera3dVector * u, Camera3dVector * v)
{
	Camera3dVector resVector;
	resVector.x = u->y*v->z - u->z*v->y;
	resVector.y = u->z*v->x - u->x*v->z;
	resVector.z = u->x*v->y - u->y*v->x;

	return resVector;
}
float operator* (Camera3dVector v, Camera3dVector u)	//dot product
{
	return v.x*u.x+v.y*u.y+v.z*u.z;
}




/***************************************************************************************/

GlCamera::GlCamera()
{
	//Init with standard OGL values:
	position = F3dVector (0.0, 0.0,	0.0);
	viewDir = F3dVector( 0.0, 0.0, -1.0);
	rightVector = F3dVector (1.0, 0.0, 0.0);
	upVector = F3dVector (0.0, 1.0, 0.0);

	//Only to be sure:
	rotatedX = rotatedY = rotatedZ = 0.0;
}

void GlCamera::move (Camera3dVector direction)
{
	position = position + direction;
}

void GlCamera::rotateX (GLfloat angle)
{
	rotatedX += angle;
	
	//Rotate viewdir around the right vector:
	viewDir = Normalize3dVector(viewDir*cos(angle*PIdiv180)
								+ upVector*sin(angle*PIdiv180));

	//now compute the new UpVector (by cross product)
	upVector = CrossProduct(&viewDir, &rightVector)*-1;

	
}

void GlCamera::rotateY (GLfloat angle)
{
	rotatedY += angle;
	
	//Rotate viewdir around the up vector:
	viewDir = Normalize3dVector(viewDir*cos(angle*PIdiv180)
								- rightVector*sin(angle*PIdiv180));

	//now compute the new RightVector (by cross product)
	rightVector = CrossProduct(&viewDir, &upVector);
}

void GlCamera::rotateZ (GLfloat angle)
{
	rotatedZ += angle;
	
	//Rotate viewdir around the right vector:
	rightVector = Normalize3dVector(rightVector*cos(angle*PIdiv180)
								+ upVector*sin(angle*PIdiv180));

	//now compute the new UpVector (by cross product)
	upVector = CrossProduct(&viewDir, &rightVector)*-1;
}

void GlCamera::render( void )
{

	//The point at which the camera looks:
	Camera3dVector viewPoint = position+viewDir;

	//as we know the up vector, we can easily use gluLookAt:
	gluLookAt(	position.x,position.y,position.z,
				viewPoint.x,viewPoint.y,viewPoint.z,
				upVector.x,upVector.y,upVector.z);

}

void GlCamera::moveForward( GLfloat distance )
{
	position = position + (viewDir*-distance);
}

void GlCamera::strafeRight ( GLfloat distance )
{
	position = position + (rightVector*distance);
}

void GlCamera::moveUpward( GLfloat distance )
{
	position = position + (upVector*distance);
}