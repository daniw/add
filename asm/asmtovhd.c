#include <stdio.h>
#include <string.h>

#define BOOL int
#define false 0
#define true (!false)

#define EXITWITHERROR(er) printf(er); if(isInteractive){fflush(stdin);getchar();} return 0;

#define MAXMIMAL_INSTRUCTIONS 1028

 typedef struct {         /* deklariert den Strukturtyp person */
    char op[30];
    char Rdest[30];
	char Rsrc1[30];
	char Rsrc2[30];
	char label[30];
	char VHDL[256];
  } sInstructLine;

int main(int argc, char *argv[]) {
    
	BOOL isInteractive = true;
	char sourceFileName[256];
	char destinationFileName[256];
	FILE* asmFile = 0;
	char oneword[512];
	sInstructLine instLines[MAXMIMAL_INSTRUCTIONS];
	int numOfInstr = 0;
	int i;

	//init instruction array
	for(i = 0;i<MAXMIMAL_INSTRUCTIONS;i++)
	{
		instLines[i].VHDL[0] = 0;
		instLines[i].label[0] = 0;
		instLines[i].op[0] = 0;
		instLines[i].Rdest[0] = 0;
		instLines[i].Rsrc1[0] = 0;
		instLines[i].Rsrc2[0] = 0;
	}

	printf("numer of startparamter: %d\n",argc);

	if(argc == 3)
	{
		strcpy(sourceFileName,argv[1]);
		strcpy(destinationFileName,argv[2]);
		isInteractive = false;
	}
	
	if(isInteractive) // read parameter in interactive mode
	{
		printf("reading Assembler from: ");
		scanf("%s",sourceFileName);
		printf("writing VHDL to: ");
		scanf("%s",destinationFileName);
	}

	printf("read asm from %s\n",sourceFileName);
	asmFile = fopen(sourceFileName, "r");

	if (!asmFile) { EXITWITHERROR("error: can not open asm file\n")}

	while( fscanf(asmFile,"%s",oneword) != EOF)
	{
		sInstructLine* aktInstr = &instLines[numOfInstr];

		if(oneword[0] == '#')	//ignore comments
		{
			char c;
			do
			{
				 c = fgetc(asmFile);
			}while((c != '\n') && (c != EOF));
		}
		else if((!strcmp("add",oneword)) || 
				(!strcmp("sub",oneword)) || 
				(!strcmp("andi",oneword)) || 
				(!strcmp("ori",oneword)) || 
				(!strcmp("xori",oneword))
				)
		{
			strcpy(aktInstr->op,oneword);
			fscanf(asmFile,"%s %s %s",aktInstr->Rdest,aktInstr->Rsrc1,aktInstr->Rsrc2);
			sprintf(aktInstr->VHDL,"OPC(%s)   & reg(%s) & reg(%s) & reg(%s) & \"--\"",aktInstr->op,aktInstr->Rdest,aktInstr->Rsrc1,aktInstr->Rsrc2);
			numOfInstr++;
		}
		else if((!strcmp("slai",oneword)) || 
				(!strcmp("srai",oneword)) || 
				(!strcmp("mov",oneword)) ||
				(!strcmp("ld",oneword)) ||
				(!strcmp("st",oneword))
				)
		{
			strcpy(aktInstr->op,oneword);
			fscanf(asmFile,"%s %s",aktInstr->Rdest,aktInstr->Rsrc1);
			sprintf(aktInstr->VHDL,"OPC(%s)   & reg(%s) & reg(%s) & \"---\"  & \"--\"",aktInstr->op,aktInstr->Rdest,aktInstr->Rsrc1);
			numOfInstr++;
		}
		else if((!strcmp("addil",oneword)) || 
				(!strcmp("addih",oneword)) || 
				(!strcmp("setil",oneword)) || 
				(!strcmp("setih",oneword))
				)
		{
			strcpy(aktInstr->op,oneword);
			fscanf(asmFile,"%s %s",aktInstr->Rdest,aktInstr->Rsrc1);
			sprintf(aktInstr->VHDL,"OPC(%s)   & reg(%s) & %s",aktInstr->op,aktInstr->Rdest,aktInstr->Rsrc1);
			numOfInstr++;
		}
		else if((!strcmp("ld",oneword)) || 
				(!strcmp("st",oneword))
				)
		{
			strcpy(aktInstr->op,oneword);
			fscanf(asmFile,"%s %s",aktInstr->Rdest,aktInstr->Rsrc1);
			sprintf(aktInstr->VHDL,"OPC(%s)   & reg(%s) & %s",aktInstr->op,aktInstr->Rdest,aktInstr->Rsrc1);
			numOfInstr++;
		}
		else if((!strcmp("jmp",oneword)) || 
				(!strcmp("bne",oneword)) || 
				(!strcmp("bge",oneword)) || 
				(!strcmp("blt",oneword))
				)
		{
			strcpy(aktInstr->op,oneword);
			fscanf(asmFile,"%s",aktInstr->Rdest);
			sprintf(aktInstr->VHDL,"OPC(%s)   & \"---\"  & \"%s\"",aktInstr->op,aktInstr->Rdest);
			numOfInstr++;
		}
		else if((!strcmp("nop",oneword))
				)
		{
			strcpy(aktInstr->op,oneword);
			sprintf(aktInstr->VHDL,"OPC(%s)   & \"---\"  & \"---\"  & \"---\"  & \"--\"",aktInstr->op);
			numOfInstr++;
		}
		else
		{
			printf("error Unknown instruction: %s\n",oneword);     
		}

		printf("conmpile: %s\n",oneword);     
	}            

	fclose(asmFile);



	if(isInteractive)
	{
		fflush(stdin);
		getchar();
	}

    return 0;
}
