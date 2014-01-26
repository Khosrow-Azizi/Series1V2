module series1::Ranking

import List;

lrel[list[int] lofc, str rank, str mYears] locRanking = [<[0..66],"++","0 to 8">, <[66..246],"+","8 to 30">, <[246..665],"o","30 to 80">, <[665..1310],"-","80 to 160">];
lrel[list[int] percentage, str rank] duplicatesRanking = [<[0..3],"++">, <[3..5],"+">, <[5..10],"o">, <[10..20],"-">];

public tuple[str rank, str mYears] determineLocRanking(int number){
    int index = 0;
	for (r <- locRanking.lofc)
	{
    	if (number/1000 in r )
    		return <locRanking.rank[index], locRanking.mYears[index]>;
     	index += 1;
    }
    return <"--", "greater 160">;
}

public str determineDupsRanking(int percentage){
	for(r <- duplicatesRanking)
		if(percentage in r.percentage)
			return r.rank;
    return "--";
}

public str determineCyclComRanking(int low, int moderate, int high, int veryHigh){
	if(moderate <= 25 && high == 0 && veryHigh == 0)
		return "++";
	if(moderate <= 30 && high <= 5 && veryHigh == 0)
		return "+";
	if(moderate <= 40 && high <= 10 && veryHigh == 0)
		return "o";
	if(moderate <= 50 && high <= 15 && veryHigh <= 5)
		return "-";
	return "--";
}

public str detemineUnitSizeRanking(int low, int moderate, int high, int veryHigh) {
	if(moderate <= 25 && high == 0 && veryHigh == 0)
		return "++";
	if(moderate <= 30 && high <= 5 && veryHigh == 0)
		return "+";
	if(moderate <= 40 && high <= 10 && veryHigh == 0)
		return "o";
	if(moderate <= 50 && high <= 15 && veryHigh <= 5)
		return "-";
	return "--";
}