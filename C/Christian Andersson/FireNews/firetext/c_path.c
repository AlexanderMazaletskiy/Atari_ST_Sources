#include "firetext.h"

/********************************************************************/
/********************************************************************/
void init_pathwin(void)
{
  short dummy;

  rsrc_gaddr(R_TREE,PATHS,&path_win.dialog);
  strncpy(path_win.w_name,alerts[W_PATHS],MAXWINSTRING);
  path_win.attr=NAME|MOVE|CLOSE;
  path_win.icondata=NULL;
  path_win.status=WINDOW_CLOSED;
  form_center(path_win.dialog, &dummy, &dummy, &dummy, &dummy);
}
/********************************************************************/
/********************************************************************/
void open_pathwin(void)
{
  strcpy(t_config.areasbbsfile,config->areasbbsfile);
  strcpy(t_config.lednewfile,config->lednewfile);
  open_dialog(&path_win);
}
/********************************************************************/
/* Hantering av s�kv�gs-installations-f�nstret                      */
/********************************************************************/
void check_pathwin(RESULT svar)
{
  char path[MAXSTRING],file[MAXSTRING];
  short  dummy;

  if((svar.type==WINDOW_CLICKED)&&(svar.data[0]==WM_CLOSED))
  {
    close_dialog(&path_win);
    menu_icheck(menu_tree,MENU_CONF_PATH,FALSE);
    menu_ienable(menu_tree,MENU_CONF_PATH,TRUE);
  }
  else if(svar.type==DIALOG_CLICKED)
    switch(svar.data[0])
    {
      case PATH_LEDNEW:
        strcpy(path,t_config.lednewfile);
        strcpy(strrchr(path,'\\')+1,"*.*");
        strcpy(file,strrchr(t_config.lednewfile,'\\')+1);
        fsel_exinput(path,file,&dummy,"Select AREAS.BBS File.");
        if(dummy)
        {
          strcpy(t_config.lednewfile,path);
          strcpy(strrchr(t_config.lednewfile,'\\')+1,file);
          str2ted(path_win.dialog,PATH_LEDNEW,t_config.lednewfile);
          button(&path_win,PATH_LEDNEW,CLEAR_STATE,SELECTED);
        }
        break;
      case PATH_AREASBBS:
        strcpy(path,t_config.areasbbsfile);
        strcpy(strrchr(path,'\\')+1,"*.*");
        strcpy(file,strrchr(t_config.areasbbsfile,'\\')+1);
        fsel_exinput(path,file,&dummy,"Select AREAS.BBS File.");
        if(dummy)
        {
          strcpy(t_config.areasbbsfile,path);
          strcpy(strrchr(t_config.areasbbsfile,'\\')+1,file);
          str2ted(path_win.dialog,PATH_AREASBBS,t_config.areasbbsfile);
          button(&path_win,PATH_AREASBBS,CLEAR_STATE,SELECTED);
        }
        break;
      case PATH_CANCEL:
        close_dialog(&path_win);
        menu_icheck(menu_tree,MENU_CONF_PATH,FALSE);
        menu_ienable(menu_tree,MENU_CONF_PATH,TRUE);
        button(&path_win, PATH_CANCEL, CLEAR_STATE, SELECTED);
        break;
      case PATH_OK:
        strcpy(config->areasbbsfile,t_config.areasbbsfile);
        strcpy(config->lednewfile,t_config.lednewfile);
        close_dialog(&path_win);
        menu_icheck(menu_tree,MENU_CONF_PATH,FALSE);
        menu_ienable(menu_tree,MENU_CONF_PATH,TRUE);
        break;
      default:;
    }
}