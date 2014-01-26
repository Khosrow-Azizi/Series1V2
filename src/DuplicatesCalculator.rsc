module series1::DuplicatesCalculator

import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core; 
import IO;
import List;
import String;
import Set;
import DateTime;

import series1::LinesOfCodeCalculator;
import series1::SourceCodeFilter;

public map[str searchPattern, set[loc] dupLOCs] allFoundDuplicates = ();
set[loc] emptyList = {};

public set[tuple[list[str] code, list[loc] locations]] foundDuplicates = {};

public map[str searchPattern, set[loc] dupLOCs] getAllDups() {
	return allFoundDuplicates;
}

public int calculateDuplications(set[loc] projectMethods, int minThreshold){
	allFoundDuplicates = ();
	//set[tuple[list[str] code, list[loc] locations]] foundDuplicates = {};
	list[tuple[loc location, list[str] sourceCode]] filterdMethods = [<m, getCleanCode(m)> | m <- projectMethods, size(getCleanCode(m)) > minThreshold];//methods(model)
	list[loc] dupLocations = [];
	
	int totalMethods = size(filterdMethods);	
	int searchPatternBegin = 0;
	int searchPatternEnd = searchPatternBegin + minThreshold;
	int searchBeginIndex = 0;
    
	for(i <- [0..totalMethods]){
	searchPatternBegin = 0;
	searchPatternEnd = searchPatternBegin + minThreshold;
		while(true){
			if(searchPatternEnd > size(filterdMethods[i].sourceCode))
				break;			
			searchPattern = filterdMethods[i].sourceCode[searchPatternBegin..searchPatternEnd];			
			dupLocations = getDups(searchPattern, filterdMethods[i].location, filterdMethods[i..totalMethods], searchPatternBegin, minThreshold);
	
			if(isEmpty(dupLocations)){
				searchPatternBegin += 1;
     			searchPatternEnd += 1; 
			}
			else{			
				foundDuplicates += 	<searchPattern, dupLocations>;
				allFoundDuplicates[intercalate("\n", searchPattern)] ? emptyList +=  {d | d <- dupLocations};				
				break;
			}
    	}      				
	}	
	
	int count = 0;
	for(dup <- foundDuplicates)	{
	 	count += (size(dup.code) * size(dup.locations));
	 }
	 iprintln(foundDuplicates.locations);
	 println("--------------------------------------------");
	 iprintln(allFoundDuplicates.dupLOCs);
	 println(count);
	 return count;
}


public list[loc] getDups(list[str] searchPattern,loc searchPatternLoc, list[tuple[loc location, list[str] sourceCode]] searchLocations, int searchBeginIdx, int threshold){
	list[loc] duplocations = [];
    int matchFromIndex;
    int matchEndIndex;
    for(l <- searchLocations){
    	if(l.location == searchPatternLoc){
			matchFromIndex = searchBeginIdx + threshold;  
    	    matchEndIndex = matchFromIndex  + threshold;
		}
		else{
			matchFromIndex = searchBeginIdx;  
    		matchEndIndex = searchBeginIdx + threshold;	
		}
		while(true){
			if(matchEndIndex > size(l.sourceCode))
				break;
			searchBlock = l.sourceCode[matchFromIndex..matchEndIndex];							
			if(searchPattern == searchBlock) {
				loc f = l.location;
				f.offset = l.location.offset + 1 + size(intercalate("\n", l.sourceCode[0..matchFromIndex]));
				f.length = size(intercalate("\n", searchBlock));
				f.begin.line = l.location.begin.line + matchFromIndex;
				f.end.line = f.begin.line + threshold - 1;
				f.begin.column = l.location.begin.column;
				f.end.column = l.location.end.column;
				duplocations += f;
			}
      		matchFromIndex += 1;
      		matchEndIndex += 1;  		
		}		
	}
	return duplocations;
}





