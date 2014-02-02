module LinesOfCodeCalculator

import List;
import String;
import IO;
import lang::java::jdt::m3::Core;

import SourceCodeFilter;

public int calculateProjectLoc(set[loc] projectFiles, list[str] comments){
	int totalLoc = 0;
	for(f <- projectFiles){
		totalLoc += calculateLoc(f, comments);
		//print("<f>: ");
		//println(calculateLoc(f, model));
	}
	return totalLoc;
}

public int calculateLoc(loc location, list[str] comments){
	return size(getCleanCode(location, comments));
}