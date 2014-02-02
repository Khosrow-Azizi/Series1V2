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
		
	//int totalLoc = calculateProjectLoc(srcFiles, comments);	
	//int totalMethodsLoc = calculateProjectLoc(srcMethods, comments);	
	int totalDublications = calculateDuplications(srcMethods, 6, comments);
	//println("Total lines: <totalLoc>");
	println("Total Dups: <totalDublications>");
	//println((toReal(totalDublications)/totalLoc) * 100);
}

// This is not finished yet
public int calculateDuplications(set[loc] projectMethods, int minThreshold, list[str] comments){
	set[list[tuple[int number, str code]]] blocks = {};
	list[tuple[int number, str code]] block = [];
	int lineNr = 0;
	for(m <- projectMethods){		
		sourceCode = getCleanCode(m, comments);
		if(size(sourceCode) >= minThreshold){
			for(code <- sourceCode){
				block += <lineNr, code>;
				lineNr += 1;
			}
		}
		blocks += block;		
	}
	 // make codeblocks of 6  or more lines
	set[map[int number, str code]] codeBlocks = {};
	list[map[int number, str code]] duplist = [];
     for(lines <- blocks){
    	len = size(lines)+1;
    	a =  [slice(lines,s,blocksize) | s <- [0..len], s+blocksize < len];
    	for(x <- a){
    		if( x in codeBlocks ){
    			duplist += x;
    		}else{
    			codeBlocks += x;
    		}
    	}
    }
	//for(l <- allCode)
		//println(l);
	//println(size(allCode));
	
	// make codeblocks of 6  or more lines
	set[int] duplicates = {};
	for(l <- dupList)
		duplicates += l;
	return size(duplicates);
}

/*private Line makeLine(str code, int lineNum){
l = Line(code);
l@nr = lineNum;
return l;
}

public real duplication(set[Declaration] ast, set[str] comments) = duplication(ast, 6, comments);

public real duplication(set[Declaration] ast, blocksize, set[str] comments){
set[list[Line]] blocks = {};
int lineCount = 0;
    for(/c:compilationUnit(package, _, _) <- ast){

    int lineNum = 0;
    cunitLines = [];
    list[str] lines = readFileLines(c@src);
	for(line <- lines){
		line = trim(line);
		if(line notin comments && size(line)>0){
			lineNum += 1;
			cunitLines += makeLine(line, lineNum);
		}
	}
   
    blocks += cunitLines;
    lineCount += lineNum;
    }
    // make codeblocks of 6  or more lines
	set[list[Line]] codeBlocks = {};
	list[Line] duplist = [];
    for(lines <- blocks){
    	len = size(lines)+1;
    	a =  [slice(lines,s,blocksize) | s <- [0..len], s+blocksize < len];
    	for(x <- a){
    		if( x in codeBlocks ){
    			duplist += x;
    		}else{
    			codeBlocks += x;
    		}
    	}
    }
    
    set[tuple[str, int]] duplicates = {};
for(l:Line(code) <- duplist){
// reduce the duplicate set to unique lines
duplicates += <code, l@nr>;
}
    return (toReal(size(duplicates))/lineCount)*100;
}
*/
