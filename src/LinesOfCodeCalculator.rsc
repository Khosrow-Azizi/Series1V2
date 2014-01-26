module series1::LinesOfCodeCalculator

import List;
import String;
import lang::java::jdt::m3::Core;

import series1::SourceCodeFilter;

public int calculateProjectLoc(set[loc] projectFiles){
	int totalLoc = 0;
	for(f <- projectFiles)
		totalLoc += calculateLoc(f);
	return totalLoc;
}

public int calculateLoc(loc location){
	return size(getCleanCode(location));
}