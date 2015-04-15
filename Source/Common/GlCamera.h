//***************************************************************************
//
// Advanced CodeColony Camera
// Philipp Crocoll, 2003
//
//***************************************************************************

#include <gl\glut.h>		// Need to include it here because the GL* types are required
#define PI 3.1415926535897932384626433832795
#define PIdiv180 (PI/180.0)

/////////////////////////////////
//Note: All angles in degrees  //
/////////////////////////////////

struct Camera3dVector  //Float 3d-vect, normally used
{
	GLfloat x,y,z;
};
/*
struct Camera2dVector
{
	GLfloat x,y;
};
*/

Camera3dVector F3dVector ( GLfloat x, GLfloat y, GLfloat z );

class GlCamera
{
private:
	Camera3dVector viewDir;
	Camera3dVector rightVector;	
	Camera3dVector upVector;
	Camera3dVector position;
	GLfloat rotatedX, rotatedY, rotatedZ;		
public:
	GlCamera();				//inits the values (Position: (0|0|0) Target: (0|0|-1) )
	void render ( void );	//executes some glRotates and a glTranslate command
							//Note: You should call glLoadIdentity before using Render

	void move ( Camera3dVector direction );
	void rotateX ( GLfloat angle );
	void rotateY ( GLfloat angle );
	void rotateZ ( GLfloat angle );

	void moveForward ( GLfloat distance );
	void noveUpward ( GLfloat distance );
	void strafeRight ( GLfloat distance );


};


