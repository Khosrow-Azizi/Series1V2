module SourceCodeFilter

import IO;
import List;
import String;

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core; 
import lang::java::m3::Core;


public set[loc] getSrcFiles(M3 model){
	 return {f | f <- files(model), isSrcEntity(f)};
}

public set[loc] getSrcMethods(set[loc] sourceFiles){
	set[loc] sourceMethods= {};	 
	for(f <- sourceFiles)
		sourceMethods += methods(createM3FromFile(f));
	return sourceMethods;
}


public bool isSrcEntity(loc entity) = 
	contains(entity.path, "/src/") && !contains(entity.path, "/generated/")
	&& !contains(entity.path, "/sample/") && !contains(entity.path, "/samples/")
	&& !contains(entity.path, "/test/") && !contains(entity.path, "/tests/") 
	&& !contains(entity.path, "/junit/") && !contains(entity.path, "/junits/");

public list[str] getCleanCode(loc location, list[str] comments){
	list[str] cleanCode = [];
    for(l <- readFileLines(location)){   
    	l = trim(l);     
       	if(l notin comments)       		
       		cleanCode += l;
    }    
    return cleanCode;
 }
 
 public list[str] getComments(M3 model)
 {
 	list[str] comments = [];
 	for(d <- model@documentation){
 		for(l <- readFileLines(d.comments))
 		comments += trim(l); 
 	}
 	return comments;
 }