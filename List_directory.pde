// list_directory(nom du dossier, extension a filtrer separés par des |);
// renvoie un array de string
class List_directory { 
 String extension;
 String[] fichiers;
 String dossier;
 int nb_items;
 
 //constructeur
 List_directory(String dossier, String extension){
   this.dossier=dossier;
   this.extension=extension;
   fichiers = listFileNames(dataPath("")+dossier, extension);
   nb_items=fichiers.length;
 }
 
 // listage le contenu d'un dossier en ne prenant que les extensions fournies -------------------------
 String[] listFileNames(String dir, String extension) {
   File file = new File(dir);
   if (file.isDirectory()) {
     String names[] = file.list();

     // procedure d'elimination des fichiers non concernés
     String[] names_ok= {};
     for(int i=0; i<names.length;i++) {
       String[] m1 = match(names[i], extension);
       if (m1 != null) {
         names_ok=append(names_ok,dossier+"/"+names[i]);
       }
     }
     return names_ok;
   } 
   else {
     // If it's not a directory
     println("le nom fourni n'est pas celui d'un dossier");
     return null;
   }
 } 
}