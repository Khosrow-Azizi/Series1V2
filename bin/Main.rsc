module series1::Main

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core; 
import lang::java::m3::Core;
import util::Math;
import util::Benchmark; 

import List;
import IO;

import series1::SourceCodeFilter;
import series1::LinesOfCodeCalculator;
//import series1::DuplicatesCalculator;
import series1::DuplicationAnalyser;
import series1::CyclomaticComplexity;
import series1::Ranking;

public loc HelloWorldLoc = |project://HelloWorld|;
public loc smallsqlLoc = |project://smallsql|; 
public loc hsqldbLoc = |project://hsqldb231|;

public void startAnalysis(loc project){
	println("Analysis started. Please wait..");
	int totalExecTime = cpuTime(void() {reportProjectMetrics(project);});
	println("Total execution time <toReal(totalExecTime)/1000000000> seconds.");
}

public void reportProjectMetrics(loc project){
	model = createM3FromEclipseProject(project);
	ast = createAstsFromEclipseProject(project, false);	
	
	set[loc] srcFiles = getSrcFiles(model);
	set[loc] srcMethods = getSrcMethods(srcFiles);
		
	int totalLoc = calculateProjectLoc(srcFiles);	
	int totalMethodsLoc = calculateProjectLoc(srcMethods);	
	int totalDublications = calculateDuplications(srcMethods, 6);
	list[tuple[str name, loc location, int complexity, int lofc]] ccAnalysisResult = getComplexityPerUnit(ast, true);
	println("Analysis <ccAnalysisResult>");
	println("====================================== Begin report ======================================");
	println("");
	
	// report on lines of code
	generateLocReport(totalLoc);
	
	println("");
	println("");	
	
	// report on CC
	generateComplexityReport(totalMethodsLoc, ccAnalysisResult);

	println("");
	println("");
	
	// unit size
	generateUnitSizeReport(totalMethodsLoc, ccAnalysisResult); // prajan : no need to call as the data is already there during
	
	println("");
	println("");
	
	// report on dupplicates
	generateDuplicateReport(totalMethodsLoc, totalDublications);
	
	println("");
	println("====================================== End report ======================================");
}

public void generateLocReport(int totalLoc){
	locRanking = determineLocRanking(totalLoc);
	println("Analysis of function point by lines of code:");
	println("	The system has got a total size of <totalLoc> lines of code.
			'	This gives a ranking of \'<locRanking.rank>\' which indicates that the man years is <locRanking.mYears>.");
}

public void generateComplexityReport(int totalMethodsLoc, list[tuple[str name, loc location, int complexity, int lofc]] ccAnalysisResult){
	int lowRiskLoc = 0;
	int modRiskLoc = 0;
	int highRiskLoc = 0;
	int veryHighRiskLoc = 0;	
	
	for(cc <- ccAnalysisResult){
	//println("Print complexity <cc.complexity>");
		if(cc.complexity <= 10) { lowRiskLoc += cc.lofc; continue; }
		if(cc.complexity > 10 && cc.complexity <= 20) { modRiskLoc += cc.lofc; continue; }
		if(cc.complexity > 20 && cc.complexity <= 50) { highRiskLoc += cc.lofc; continue; }
		veryHighRiskLoc += cc.lofc;
	}
	
	int lowRiskRatio = round((toReal(lowRiskLoc) / totalMethodsLoc) * 100);
	int modRiskRatio = round((toReal(modRiskLoc) / totalMethodsLoc) * 100);
	int highRiskRatio = round((toReal(highRiskLoc) / totalMethodsLoc) * 100);
	int veryHighRiskRatio = round((toReal(veryHighRiskLoc) / totalMethodsLoc) * 100);
	
	println("Analysis of complexity:
	'	Percentage of low risk:		<lowRiskRatio>%
	'	Percentage of moderate risk:	<modRiskRatio>%
	'	Percentage of high risk:	<highRiskRatio>%
	'	Percentage of very high risk:	<veryHighRiskRatio>%
	'	This gives the project a \'<determineCyclComRanking(lowRiskRatio, modRiskRatio, highRiskRatio, veryHighRiskRatio)>\' for Cyclomatic Complexity.");
}

public void generateUnitSizeReport(int totalMethodsLoc, list[tuple[str name, loc location, int complexity, int lofc]] ccAnalysisResult){
	int lowRiskSize = 0;
	int modRiskSize = 0;
	int highRiskSize = 0;
	int veryHighRiskSize = 0;	
	
	for(cc <- ccAnalysisResult){
		if(cc.lofc <= 10) { lowRiskSize += cc.lofc; continue; }
		if(cc.lofc > 10 && cc.lofc <= 20) { modRiskSize += cc.lofc; continue; }
		if(cc.lofc > 20 && cc.lofc <= 50) { highRiskSize += cc.lofc; continue; }
		veryHighRiskSize += cc.lofc;
	}
	
	int lowRiskRatio = round((toReal(lowRiskSize) / totalMethodsLoc) * 100);
	int modRiskRatio = round((toReal(modRiskSize) / totalMethodsLoc) * 100);
	int highRiskRatio = round((toReal(highRiskSize) / totalMethodsLoc) * 100);
	int veryHighRiskRatio = round((toReal(veryHighRiskSize) / totalMethodsLoc) * 100);
	
	println("Analysis of unit size:
	'	Percentage of low risk:		<lowRiskRatio>%
	'	Percentage of moderate risk:	<modRiskRatio>%
	'	Percentage of high risk:	<highRiskRatio>%
	'	Percentage of very high risk:	<veryHighRiskRatio>%
	'	This gives the project a \'<detemineUnitSizeRanking(lowRiskRatio, modRiskRatio, highRiskRatio, veryHighRiskRatio)>\' for Units Size.");
}
public void generateDuplicateReport(int totalMethodsLoc, int totalDuplicates){	
    int percentage = round((toReal(totalDuplicates)/totalMethodsLoc) * 100);
	println("Analysis of code duplicates:");
	println("	The system has got a total duplicates of <totalDuplicates> lines of code. 
			'	It is <percentage>% of the total size of the project.
			'	This gives a ranking of \'<determineDupsRanking(percentage)>\' for code duplicates.");
}
