// Script Cuantificacion Ariel Waisman

// ********************************************************** //
// ******* Recordar setear los measurements deseados!!!! **** //
// Las imagenes de los tres canales deben ser guardadas con una logica de nombres en donde
// el fluoroforo este al final del nombre del archivo. Por ejemplo:
// 20X-WT-D0-Foto1-DAPI.tif
// 20X-WT-D0-Foto1-Oct4-488.tif
// 20X-WT-D0-Foto1-Nanog-595.tif
// Ademas, hay que tener el plugin de Stardist instalado en FIJI
// En la carpeta donde estan las fotos, hay que crear una subcarpeta "PNGs" previo a correr el script
// para que se guarden las fotos pngs, cuyo unico objetivo es la visualizacion posterior, no el analisis.
// ********************************************************** //

run("Set Measurements...", "area mean integrated redirect=None decimal=4");

run("Close All")
//setBatchMode(true);

dir = getDirectory("Elegí un directorio");
list = getFileList(dir);
 

 for (i=0; i<list.length; i++) {
 	print("Entro");
	if (matches(list[i], ".*DAPI.tif")) { // '.' es la wildcard, cualquier elemento. y el '*' indica, repetir el comando anterior infinitas veces
		print("-------");
		print("Archivo: "+list[i]);
		path = dir+list[i]; //creo full path al archivo para q me funcione el bioformats importer mas abajo
		print(path);
		print(dir);

		// Abro el archivo DAPI
		run("Bio-Formats Importer", "open=["+path+"]" + " color_mode=Default view=Hyperstack stack_order=XYCZT");
		run("Enhance Contrast", "saturated=0.35"); // Ajusto niveles para q se vea bien

		
		// Defino titulos
		titulo_DAPI = getTitle();
		titulo_base = replace(titulo_DAPI, "-DAPI.tif", "");
		titulo_Oct4 = titulo_base + "-Oct4-488.tif";
		path_Oct4 = dir + titulo_Oct4;
		titulo_ROIs = titulo_base + "RoiSet.zip";
		titulo_tabla_Oct4 = titulo_base + "_tabla_Oct4.csv";


		titulo_Nanog = titulo_base + "-Nanog-488.tif";
		path_Nanog = dir + titulo_Nanog;
		titulo_tabla_Nanog = titulo_base + "_tabla_Nanog.csv";

		

     	print(titulo_DAPI);
		print(titulo_base);
		print(titulo_Oct4);
		print(titulo_Nanog);

		
		
		// Corro Stardist para segmentar nucleos
		run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'"+titulo_DAPI+"', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.5', 'nmsThresh':'0.4', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
		selectWindow("Label Image");
		close();
		selectWindow(titulo_DAPI);
		roiManager("Show All");
		run("Flatten");
		saveAs("PNG", dir + "PNGs/"+ titulo_DAPI);
		close();
		roiManager("Save", dir + titulo_ROIs);

		// Abro imagen Oct4
		run("Bio-Formats Importer", "open=["+path_Oct4+"]" + " color_mode=Default view=Hyperstack stack_order=XYCZT");
		
		
		// RESTO BACKGROUND: hay que hacer exploracion previa manual para determinarlo en varias fotos
		
		run("Subtract...", "value=66");
		
		run("Red");
	
		setMinAndMax(0, 2000); // Ajusto niveles para q se vea bien la imagen PNG de muestra (no afecta el analisis). Tambien lo tengo que determinar manualmente en una foto de alta expresion, con el background ya restado, cuales son los valores de min y max q hacen q se vea bien: en FIJI- Adjust birghtness and contrast
		
		
		//waitForUser("Acepta y continua");
		//setMinAndMax(2, 50);
		saveAs("PNG", dir + "PNGs/"+ titulo_Oct4);
		rename(titulo_Oct4); //ESTO ES CLAVE PARA Q SE LLAME .TIF Y NO .PNG LA IMAGEN, Y PODER LLAMARLA ENTONCES DESDE LA LINEA DE ABAJO DE MERGE
		//close();

		roiManager("Measure");
		saveAs("Results", dir+titulo_tabla_Oct4);
		run("Clear Results");



		// Abro imagen Nanog
		run("Bio-Formats Importer", "open=["+path_Nanog+"]" + " color_mode=Default view=Hyperstack stack_order=XYCZT");
		
		// RESTO BACKGROUND
		run("Subtract...", "value=80"); //hay que hacer exploracion previa manual para determinarlo en varias fotos
		run("Green");


		setMinAndMax(0, 1000); // Ajusto niveles para q se vea bien la imagen PNG de muestra (no afecta el analisis). Tambien lo tengo que determinar manualmente en una foto de alta expresion, con el background ya restado, cuales son los valores de min y max q hacen q se vea bien: en FIJI- Adjust birghtness and contrast

		
		//waitForUser("Acepta y continua");
		//setMinAndMax(2, 70);
		saveAs("PNG", dir + "PNGs/"+ titulo_Nanog);
		rename(titulo_Nanog); //ESTO ES CLAVE PARA Q SE LLAME .TIF Y NO .PNG LA IMAGEN, Y PODER LLAMARLA ENTONCES DESDE LA LINEA DE ABAJO DE MERGE
		//close();

		roiManager("Measure");
		saveAs("Results", dir+titulo_tabla_Nanog);
		run("Clear Results");


		// Imagen Merge: solo a fines de visualizacion despues, no analisis
		run("Merge Channels...", "c1=["+titulo_Oct6+"] c2=["+titulo_Nanog+"] create keep");
		saveAs("PNG", dir + "PNGs/"+ titulo_base + "_merge");
		


		roiManager("Delete");

		run("Close All");
		
	}
 }