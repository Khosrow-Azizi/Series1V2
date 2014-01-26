module series1::DuplicationAnalyser

import IO;
import List;
import Set;
import String;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core; 
import lang::java::m3::Core;
import util::Math;
import util::Benchmark; 


import series1::LinesOfCodeCalculator;
import series1::SourceCodeFilter;

public loc HelloWorldLoc = |project://HelloWorld|;
public loc smallsqlLoc = |project://smallsql|; 
public loc hsqldbLoc = |project://hsqldb|;

//public set[tuple[list[str] code, list[loc] locations]] foundDuplicates = {};
public set[tuple[list[str] dupCode, set[tuple[loc location, int occurence]] locations]] foundDuplicates = {};

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
		
	int totalLoc = calculateProjectLoc(srcFiles);	
	int totalMethodsLoc = calculateProjectLoc(srcMethods);	
	int totalDublications = calculateDuplications(srcMethods, 6);
	println("Total lines: <totalLoc>");
	println("Total Dups: <totalDublications>");
	println((toReal(totalDublications)/totalLoc) * 100);
}

public int calculateDuplications(set[loc] projectMethods, int minThreshold){
	list[tuple[loc location, list[str] sourceCode]] filterdMethods = [];
	for(m <- projectMethods){
		sourceCode = getCleanCode(m);
		if(size(sourceCode) >= minThreshold)
			filterdMethods += (<m, sourceCode>);	
	}
	
	map[list[str] dupCode, set[tuple[loc location, int occurence]] locations] foundedDupsTemp = ();
	map[set[tuple[loc location, int occurence]] locations, list[str] dupCode] filteredDups = ();
	int index = 0;
	int totalMethods = size(filterdMethods);
	for(method <- filterdMethods){
		searchBlocksize = minThreshold;
		methodSize = size(method.sourceCode);
		while(true){			
			searchPatterns = [slice(method.sourceCode, i, searchBlocksize) | i <- [0..methodSize], i + searchBlocksize < methodSize];
			for(searchPattern <- searchPatterns){
				set[tuple[loc location, int occurence]] dups = {};
				for(scanMethod <- filterdMethods[index..totalMethods]){				
					matchedPattern = scanMethod.sourceCode & searchPattern;					
					if(searchPattern <= matchedPattern && head(searchPattern) == head(matchedPattern)){									
						dups += <scanMethod.location, (size(matchedPattern)/size(searchPattern))>;										
					}					
				}
				if(!isEmpty(dups)){								
					foundedDupsTemp += (searchPattern : dups);					
				}							
		    }	    
		    if(foundedDupsTemp == ())
		    	break;
		    for(dup <- foundedDupsTemp){		    	
		    	if(size(foundedDupsTemp[dup]) < 2 && getOneFrom(foundedDupsTemp[dup]).occurence < 2)
		    		continue;
		    	if(!(foundedDupsTemp[dup] in filteredDups)){
		    		filteredDups += (foundedDupsTemp[dup] : dup);
		    		continue;
		    	}
		    	if(size(dup) > size(filteredDups[foundedDupsTemp[dup]]))
					filteredDups += (foundedDupsTemp[dup] : dup);
			}		    
		    foundedDupsTemp = ();	
		    searchBlocksize += 1;	    
		}
		index += 1;	
	}
	
	int totalDupLines = 0;
	set[str] dupSet = {};
	list[str] dupList = [];
	for(dup <- filteredDups){		
		//println("(<filteredDups[dup]> : <dup>");	
		
		dupSet += toSet(filteredDups[dup]);
		//totalDupLines += (size(filteredDups[dup]) * (0| it + location.occurence | location <- dup));
	 	foundDuplicates += <filteredDups[dup], dup>; 
	 	//println("");		
	 }
	return size(dupSet);
	// return totalDupLines;
}

