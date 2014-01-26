module series1::CyclomaticComplexity

import lang::java::jdt::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core; 
import List;
import Set;
import IO;

import series1::SourceCodeFilter;
import series1::LinesOfCodeCalculator;

public list[tuple[str name, loc location, int complexity, int lofc]] getComplexityPerUnit(set[Declaration] ast, bool scanSrcOnly){
    list[tuple[str name, loc location, int complexity, int lofc]] result = [];
	visit(ast){
		case method(_, str methodName, _, _, Statement impl) : {
			if(scanSrcOnly){
				if(isSrcEntity(impl@src))
					result += <methodName, impl@src, calculateCC(impl), calculateLoc(impl@src)>;
			}								
		}
	}
	return result;
}

public int calculateCC(Statement stat){
	count = 1;
	visit(stat){
		case \if(_, _): count += 1;
		case \if(_, _,_): count += 1;
		case \case(_): count += 1;
		case \foreach(_, _, _): count += 1;
		case \for(_, _, _): count += 1;
		case \for(_, _, _, _): count += 1;
		case \do(_, _): count += 1;
		case \while(_, _): count += 1;
		case \catch(_, _): count += 1;			
	}
	return count;
}