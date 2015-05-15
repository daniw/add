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


char* genSpaceString(int numOfSpaces,char* buffer);
void saveSourceFileName(char* name);
void loadSourceFileName(char* name);

int main(int argc, char *argv[]) {
    
	BOOL isInteractive = true;
	char sourceFileName[256];
	char destinationFileName[256];
	FILE *asmFile = 0, *VhdlFile = 0;
	char oneword[512];
	char spaceAlign[20];
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
		sourceFileName[0] = 0;

		while(!sourceFileName[0]) //until correct input or default input
		{
			loadSourceFileName(sourceFileName);
			printf("reading Assembler from [%s]: ",sourceFileName);
			fflush(stdin);
			scanf("%[^\n]",sourceFileName); //read a line
		}
		saveSourceFileName(sourceFileName);
		
		

		printf("writing VHDL to [rom.vhd]: ");
		destinationFileName[0] = 0;
		fflush(stdin);
		scanf("%[^\n]",destinationFileName); //read a line
		if(!(*destinationFileName))			 //emty input = default file
		{
			strcpy(destinationFileName,"rom.vhd");
		}
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
			genSpaceString(5-strlen(oneword),spaceAlign);
			fscanf(asmFile,"%s %s %s",aktInstr->Rdest,aktInstr->Rsrc1,aktInstr->Rsrc2);
			sprintf(aktInstr->VHDL,"OPC(%s)%s   & reg(%s) & reg(%s) & reg(%s) & \"--\"",aktInstr->op,spaceAlign,aktInstr->Rdest,aktInstr->Rsrc1,aktInstr->Rsrc2);
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
			genSpaceString(5-strlen(oneword),spaceAlign);
			fscanf(asmFile,"%s %s",aktInstr->Rdest,aktInstr->Rsrc1);
			sprintf(aktInstr->VHDL,"OPC(%s)%s   & reg(%s) & reg(%s) & \"---\"  & \"--\"",aktInstr->op,spaceAlign,aktInstr->Rdest,aktInstr->Rsrc1);
			numOfInstr++;
		}
		else if((!strcmp("addil",oneword)) || 
				(!strcmp("addih",oneword)) || 
				(!strcmp("setil",oneword)) || 
				(!strcmp("setih",oneword))
				)
		{
			strcpy(aktInstr->op,oneword);
			genSpaceString(5-strlen(oneword),spaceAlign);
			fscanf(asmFile,"%s %s",aktInstr->Rdest,aktInstr->Rsrc1);
			sprintf(aktInstr->VHDL,"OPC(%s)%s   & reg(%s) & %s",aktInstr->op,spaceAlign,aktInstr->Rdest,aktInstr->Rsrc1);
			numOfInstr++;
		}
		else if((!strcmp("ld",oneword)) || 
				(!strcmp("st",oneword))
				)
		{
			strcpy(aktInstr->op,oneword);
			genSpaceString(5-strlen(oneword),spaceAlign);
			fscanf(asmFile,"%s %s",aktInstr->Rdest,aktInstr->Rsrc1);
			sprintf(aktInstr->VHDL,"OPC(%s)%s   & reg(%s) & %s",aktInstr->op,spaceAlign,aktInstr->Rdest,aktInstr->Rsrc1);
			numOfInstr++;
		}
		else if((!strcmp("jmp",oneword)) || 
				(!strcmp("bne",oneword)) || 
				(!strcmp("bge",oneword)) || 
				(!strcmp("blt",oneword)) ||
				(!strcmp("bca",oneword)) ||
				(!strcmp("bov",oneword))
				)
		{
			strcpy(aktInstr->op,oneword);
			genSpaceString(5-strlen(oneword),spaceAlign);
			fscanf(asmFile,"%s",aktInstr->Rdest);
			sprintf(aktInstr->VHDL,"OPC(%s)%s   & \"---\"  & %s",aktInstr->op,spaceAlign,aktInstr->Rdest);
			numOfInstr++;
		}
		else if((!strcmp("nop",oneword))
				)
		{
			genSpaceString(5-strlen(oneword),spaceAlign);
			strcpy(aktInstr->op,oneword);
			sprintf(aktInstr->VHDL,"OPC(%s)%s   & \"---\"  & \"---\"  & \"---\"  & \"--\"",aktInstr->op,spaceAlign);
			numOfInstr++;
		}
		else
		{
			printf("error Unknown instruction: %s\n",oneword);     
		}

		printf("conmpile: %s\n",oneword);     
	}            

	fclose(asmFile);


//--------------write----------------------------------------------------------------------------------------------------------------------------------
	printf("write VHSL to %s\n",destinationFileName);

	VhdlFile = fopen(destinationFileName,"w");

	fprintf(VhdlFile,"-------------------------------------------------------------------------------\n");
	fprintf(VhdlFile,"-- Entity: rom\n");
	fprintf(VhdlFile,"-- Author: Waj\n");
	fprintf(VhdlFile,"-- Date  : 11-May-13, 26-May-13\n");
	fprintf(VhdlFile,"-------------------------------------------------------------------------------\n");
	fprintf(VhdlFile,"-- Total # of FFs: DW\n");
	fprintf(VhdlFile,"-------------------------------------------------------------------------------\n");
	fprintf(VhdlFile,"library ieee;\n");
	fprintf(VhdlFile,"use ieee.std_logic_1164.all;\n");
	fprintf(VhdlFile,"use ieee.numeric_std.all;\n");
	fprintf(VhdlFile,"use work.mcu_pkg.all;\n");
	fprintf(VhdlFile,"entity rom is\n");
	fprintf(VhdlFile,"  port(clk     : in    std_logic;\n");
	fprintf(VhdlFile,"       -- ROM bus signals\n");
	fprintf(VhdlFile,"       bus_in  : in  t_bus2ros;\n");
	fprintf(VhdlFile,"       bus_out : out t_ros2bus\n");
	fprintf(VhdlFile,"       );\n");
	fprintf(VhdlFile,"end rom;\n");
	fprintf(VhdlFile,"\n");
	fprintf(VhdlFile,"architecture rtl of rom is\n");
	fprintf(VhdlFile,"  type t_rom is array (0 to 2**AWL-1) of std_logic_vector(DW-1 downto 0);\n");
	fprintf(VhdlFile,"  constant rom_table : t_rom := (\n");
	fprintf(VhdlFile,"    ---------------------------------------------------------------------------\n");
	fprintf(VhdlFile,"    -- program code -----------------------------------------------------------\n");
	fprintf(VhdlFile,"    ---------------------------------------------------------------------------\n");
	fprintf(VhdlFile,"    -- addr    Opcode     Rdest    Rsrc1    Rsrc2              description\n");
	fprintf(VhdlFile,"    ---------------------------------------------------------------------------\n");
	fprintf(VhdlFile,"         -- auto generated by asmtovhd from %s\n",sourceFileName);

	for(i=0;i<numOfInstr;i++)
	{
		fprintf(VhdlFile,"      %d => %s,            -- \n",i,instLines[i].VHDL);
	}

	fprintf(VhdlFile,"      others    => (others => '1')\n");
	fprintf(VhdlFile,"         );\n");
	fprintf(VhdlFile,"\n");
	fprintf(VhdlFile,"begin\n");
	fprintf(VhdlFile,"\n");
	fprintf(VhdlFile,"  -----------------------------------------------------------------------------\n");
	fprintf(VhdlFile,"  -- sequential process: ROM table with registerd output\n");
	fprintf(VhdlFile,"  ----------------------------------------------------------------------------- \n");
	fprintf(VhdlFile,"  P_rom: process(clk)\n");
	fprintf(VhdlFile,"  begin\n");
	fprintf(VhdlFile,"    if rising_edge(clk) then\n");
	fprintf(VhdlFile,"      bus_out.data <= rom_table(to_integer(unsigned(bus_in.addr)));\n");
	fprintf(VhdlFile,"    end if;\n");
	fprintf(VhdlFile,"  end process;\n");
	fprintf(VhdlFile,"\n");
	fprintf(VhdlFile,"end rtl;\n");

	fclose(VhdlFile);

	if(isInteractive)
	{
		printf("success, press any key to continue..\n");
		fflush(stdin);
		getchar();
	}

    return 0;
}

char* genSpaceString(int numOfSpaces,char* buffer)
{
	int i;
	for(i=0;i<numOfSpaces;i++)
	{
		buffer[i] = ' ';
	}
	buffer[numOfSpaces] = 0;
	return buffer;
}

void saveSourceFileName(char* name)
{
	FILE* f = fopen("asmtovhd_settings.txt","w");
	if(f)
	{
		fprintf(f,"%s",name);
		fclose(f);
	}
}

void loadSourceFileName(char* name)
{
	FILE* f= fopen("asmtovhd_settings.txt","r");;
	name[0] = 0;
	if(f)
	{
		fscanf(f,"%s",name);
		fclose(f);
	}
}
