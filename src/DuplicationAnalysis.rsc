module DuplicationAnalysis

import IO;
import List;
import Set;
import String;
import Map;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core; 
import lang::java::m3::Core;
import util::Math;
import util::Benchmark; 


import LinesOfCodeCalculator;
import SourceCodeFilter;

public loc HelloWorldLoc = |project://HelloWorld|;
public loc smallsqlLoc = |project://smallsql|; 
public loc hsqldbLoc = |project://hsqldb|;

private data LineOfCode = LineOfCode(map[int number, str code]);


public void startAnalysis(loc project){
	println("Analysis started. Please wait..");
	int totalExecTime = cpuTime(void() {reportProjectMetrics(project);});
	println("Total execution time <toReal(totalExecTime)/1000000000> seconds.");
}

public void reportProjectMetrics(loc project){
	model = createM3FromEclipseProject(project);
	
//	for(d <- model@documentation)
	//	println(d);
	
	set[loc] srcFiles = getSrcFiles(model);
	set[loc] srcMethods = getSrcMethods(srcFiles);
//	for(m <-srcMethods)
		//println(m.file);
		
	list[str] comments = getComments(model);
		
	
	int totalDublications = calculateDuplications(srcMethods, 6, comments);
	
	println("Total Dups: <totalDublications>");
	//println((toReal(totalDublications)/totalLoc) * 100);
}

public int calculateDuplications(set[loc] projectMethods, int minThreshold, list[str] comments){
	set[list[str]] scanedBlocks = {};
	set[str] dupSet = {};
	for(m <- projectMethods){		
		sourceCode = getCleanCode(m, comments);
		blockLength = size(sourceCode) + 1;		
		if(blockLength >= minThreshold){
			searchPatterns = [slice(sourceCode, beginIndex, minThreshold) | beginIndex <- [0..blockLength], beginIndex + minThreshold < blockLength];
			for(pattern <- searchPatterns){
				if(pattern in scanedBlocks)
					dupSet += toSet(pattern);
				else
					scanedBlocks += pattern;					
			}			
		}	
	}
	return size(dupSet);
}