#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2
#define DIALOG_SUCCESS_1 3
#define DIALOG_SUCCESS_2 4

#define PATH "/User/%s.ini"

// SYSTEM ZOMBIE MENGGUNAKAN RPNC
#define HOLDING(%0) ((newkeys & (%0)) == (%0))
#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define MAX_ZOMBIES 8
#define ZOMBIE_SKIN 162
#define ZOMBIE_COLOUR 0xFF0000FF
#define ZOMBIE_DAMAGE 20
#define ZOMBIE_DETECT 100
#define MAX_MOVEMENT 6
#define MAX_ROAM 10
#define RUNNER_ZOMBIE 0
#define SPRINTER_ZOMBIE 1