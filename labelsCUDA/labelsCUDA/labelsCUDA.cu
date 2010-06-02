// test2.cpp : Defines the entry point for the console application.
//

//#include "stdafx.h"
//
//
//int _tmain(int argc, _TCHAR* argv[])
//{
//	return 0;
//}

//#include <C:\Program Files\NVIDIA Nexus 1.0\CUDA Toolkit\v3.0\Win32\CUDA\include\thrust/version.h>
//#include <C:\Program Files\NVIDIA Nexus 1.0\CUDA Toolkit\v3.0\Win32\CUDA\include\thrust/device_vector.h>

#include <cuda_runtime_api.h>
#include "CudaUtil.h"
//#include <thrust/host_vector.h>
//#include <thrust/device_vector.h>
//
//#include <thrust/copy.h>
//#include <thrust/fill.h>
//#include <thrust/sequence.h>

#include <iostream>
//#include <FileLoader.h>
#include "FileStruct.h"
#include "Word.h"

#include "..\WordFinder\WordFinderLib.h"
#include "..\cudpp\include\cudpp.h"


void Foo();

__global__ void
test(char *a, int len)
{
    // Block index
    int bx = blockIdx.x;
    int by = blockIdx.y;

    // Thread index
    int tx = threadIdx.x;
	int ty = threadIdx.y;

	int idx = threadIdx.x + blockDim.x * blockIdx.x;
	if (idx < len)
	{
		a[idx] = a[idx]+1;
	}
}

int PrintDevices(int deviceCount, int deviceSelected)
{
    cudaError_t err = cudaSuccess;

    cudaDeviceProp deviceProperty;
    for (int currentDeviceId = 0; currentDeviceId < deviceCount; ++currentDeviceId)
    {
        memset(&deviceProperty, 0, sizeof(cudaDeviceProp));
        err = cudaGetDeviceProperties(&deviceProperty, currentDeviceId);
        //CheckConditionXR_(err == cudaSuccess, err);

        printf("\ndevice name: %s", deviceProperty.name);
        if (currentDeviceId == deviceSelected)
        {
            printf("    <----- creating CUcontext on this");    
        }
        printf("\n");

        printf("device sharedMemPerBlock: %d \n", deviceProperty.sharedMemPerBlock);
        printf("device totalGlobalMem: %d \n", deviceProperty.totalGlobalMem);
        printf("device regsPerBlock: %d \n", deviceProperty.regsPerBlock);
        printf("device warpSize: %d \n", deviceProperty.warpSize);
        printf("device memPitch: %d \n", deviceProperty.memPitch);
        printf("device maxThreadsPerBlock: %d \n", deviceProperty.maxThreadsPerBlock);
        printf("device maxThreadsDim[0]: %d \n", deviceProperty.maxThreadsDim[0]);
        printf("device maxThreadsDim[1]: %d \n", deviceProperty.maxThreadsDim[1]);
        printf("device maxThreadsDim[2]: %d \n", deviceProperty.maxThreadsDim[2]);
        printf("device maxGridSize[0]: %d \n", deviceProperty.maxGridSize[0]);
        printf("device maxGridSize[1]: %d \n", deviceProperty.maxGridSize[1]);
        printf("device maxGridSize[2]: %d \n", deviceProperty.maxGridSize[2]);
        printf("device totalConstMem: %d \n", deviceProperty.totalConstMem);
        printf("device major: %d \n", deviceProperty.major);
        printf("device minor: %d \n", deviceProperty.minor);
        printf("device clockRate: %d \n", deviceProperty.clockRate);
        printf("device textureAlignment: %d \n", deviceProperty.textureAlignment);
        printf("device deviceOverlap: %d \n", deviceProperty.deviceOverlap);
        printf("device multiProcessorCount: %d \n", deviceProperty.multiProcessorCount);

        printf("\n");
    }

    return cudaSuccess;
}

int main()
{
	//PrintDevices(1,0);

	Foo();
	return;


	//char * buf;
	//int size = LoadFile(".\\goog0.txt", buf);
	//if (size < 10)
	//{
	//	std::cout << "error opening file";
	//	return;
	//}
	//printf("size: %d, text: %s \n", size, buf);

	//int len = 320;
	////// allocate device memory
 ////   int* a;
 ////   cudaMalloc((void**) &a, len * sizeof (int));
 ////   int* b;
 ////   cudaMalloc((void**) &b, len * sizeof (int));

	//char* deviceBuf;
 //   cudaMalloc((void**) &deviceBuf, size);
	//cudaMemcpy(deviceBuf, buf, size, cudaMemcpyHostToDevice);
	FileStruct* file = new FileStruct(".\\goog0.txt");
	size_t size = file->GetSize();
	
	char * deviceBuffer = file->GetDeviceBuffer();
	// setup execution parameters
    dim3 threads(512, 1);
    dim3 grid(size/512,1);

    // execute the kernel
    test<<< grid, threads >>>(deviceBuffer, size);
	
	char* buf =(char*) malloc(size + 1);
	cudaMemcpy(buf, deviceBuffer, size, cudaMemcpyDeviceToHost);

	//cudaFree(deviceBuf);
    // print a
	printf("text2: %s", buf);
    //for(int i = 0; i < size; i++)
    //    std::cout << "A[" << i << "] = " << buf[i] << std::endl;
	free(buf);
	getchar();
	delete file;
    return 0;
}

char* Test2(char* text, size_t size)
{
	char * a;
    cudaMalloc((void**) &a, size);

	cudaMemcpy(a, text, size, cudaMemcpyHostToDevice);
	
	return a;
}


int host_FindAllWords(Transition* table, char* text, Word* words )
{
	int wordsCount = 0;
	int state = 0;
	Transition trans;
	for (int i = 0; text[i] != 0; ++i)
	{
		trans = GetTransaction(table, state, text[i]);

		if (trans.Output != 0)
		{
			Word word;
			word.Id = trans.Output;
			word.Pos = i;
			words[wordsCount++] = word;
		}
		state = trans.NextState;
	}

	return wordsCount;
} 

//__global__ void
//device_FindAllWords(Transition* table, char* text, int len, Word* words, int* count, int * allWords, int* allCount)
//{
//    // Block index
//    int bx = blockIdx.x;
//    int by = blockIdx.y;
//
//    // Thread index
//    int tx = threadIdx.x;
//	int ty = threadIdx.y;
//	__shared__ int wordsCount;
//	__global__ int allWords[blockDim.x];
//	__shared__ int allWordsCount;
//
//	if (tx == 0)
//	{
//		wordsCount = 0;
//		allWordsCount = 0;
//	}
//
//	int idx = threadIdx.x + blockDim.x * blockIdx.x;
//	if (tx < len)
//	{
//		if (text[tx] == ' ')
//		{		
//			allWords[allWordsCount] = idx;
//		}
//		else
//		{
//			allWords[tx] = 0;
//		}
//	}
//	__syncthreads();
//	if (tx==0)
//	{
//
//	}
//			/*int state = 0;
//			int output;
//			idx++;
//			do
//			{
//				Transition trans = GetTransaction(table, state, text[idx]);
//				idx++;
//				state = trans.NextState;
//				output = trans.Output;
//				if (output != 0)
//				{					
//					atomicAdd(&wordsCount, 1);
//				}					
//			}
//			while((state != 0) && (idx < len));*/
//		
//		
//		//text[idx] = text[idx];
//
//}

__global__ void
device_MarkAllWords(char* text, int len, int* terminatedSymbols)
{
    // Block index
    int bx = blockIdx.x;
    int by = blockIdx.y;

    // Thread index
    int tx = threadIdx.x;
	int ty = threadIdx.y;


	int idx = threadIdx.x + blockDim.x * blockIdx.x;
	if (idx < len)
	{
		char c = text[idx];
		terminatedSymbols[idx] = (
			(c == ' ')||
			(c == '.')||
			(c == ',')||
			(c == '!')||
			(c == '?'));		
	}
}

__global__ void
device_ExctractAllWords(int* position, int len, int* allCount)
{
    // Block index
    int bx = blockIdx.x;
    int by = blockIdx.y;

    // Thread index
    int tx = threadIdx.x;
	int ty = threadIdx.y;
	extern __shared__ int cached[];
	int pos = position[tx];
	cached[tx] = pos;
	__syncthreads();
	int idx = threadIdx.x + blockDim.x * blockIdx.x;
	if (idx < len)
	{
		int posPrev;
		if (tx!= 0)
		{
			posPrev = cached[tx-1];
		}
		else
		{
			posPrev = position[idx-1];
		}

		if (posPrev != pos)
		{
			position[pos] = idx;
		}
	}

	if (idx == len)
	{
		*allCount = pos;
	}
}


__global__ void
device_FindAllWords(Transition* table, char* text, int len, int* position, size_t* count, int* words)
{
    // Block index
    int bx = blockIdx.x;
    int by = blockIdx.y;

    // Thread index
    int tx = threadIdx.x;
	int ty = threadIdx.y;

	int idx = threadIdx.x + blockDim.x * blockIdx.x;
	if (idx < *count)
	{
		int state = 0;
		int pos = position[idx];
		int output;
		pos++;
		Transition trans;
		do
		{
			trans = GetTransaction(table, state, text[pos]);
			pos++;
			state = trans.NextState;
		}
		while((state != 0) && (pos < len));
		words[idx]	= trans.Output;			
	}
}

__global__ void
device_WatchDebug(char * str)
{
    // Block index
    int bx = blockIdx.x;
    int by = blockIdx.y;

    // Thread index
    int tx = threadIdx.x;
	int ty = threadIdx.y;

	int idx = threadIdx.x + blockDim.x * blockIdx.x;
	char * s = str;
	s[tx] = 'B';
}

bool FindedWordsEqual(Word * w1, int count1, Word* w2, int count2)
{
	bool result;
	if (count1 = count2)
	{
		result = (memcmp(w1, w2, count1* sizeof(Word)) == 0);
	}
	else
	{
		result = false;
	}
	return result;
}




void deviceFindAllWords(Transition* table, char* text, int len, Word* words, int* count, int * allWords, int* allCount)
{
	// setup execution parameters
    dim3 threads(512, 1);
    dim3 grid((len-1)/512+1,1);
	int* terminatedSymbols;
	int num_elements = len;
	int mem_size = sizeof( int) * num_elements;

	cudaMalloc(&terminatedSymbols, mem_size);
	device_MarkAllWords<<< grid, threads >>>(text, len, terminatedSymbols);
	

	// allocate device memory output arrays
    int* d_idata = terminatedSymbols;
    int* d_odata = NULL;

    cudaMalloc( (void**) &d_odata, mem_size);

	CUDPPConfiguration config;	
	config.datatype = CUDPP_INT;
	config.algorithm = CUDPP_COMPACT;
	config.options = CUDPP_OPTION_FORWARD | CUDPP_OPTION_EXCLUSIVE |CUDPP_OPTION_INDEX;
    
    CUDPPHandle scanplan = 0;
    CUDPPResult result = cudppPlan(&scanplan, config, len, 1, 0); 
	//Buffer wordsCountBuf(sizeof(size_t));
	size_t* pwordsCount;
    cudaMalloc( (void**) &pwordsCount, sizeof(size_t));

	cudppCompact(scanplan, d_odata, pwordsCount, text,(unsigned int*) terminatedSymbols, len);
	
	//printf("Words count: %d \n", *(int*)(wordsCountBuf.GetHost()) );
	//device_WatchDebug<<< 1, 1 >>>((char*)wordsCountBuf.GetDevice());

	Buffer wordsId(pwordsCount);
	cudppDestroyPlan(scanplan);
	
	device_FindAllWords<<< 2, 512 >>>(table, text, len, d_odata, pwordsCount, (int*) wordsId.GetDevice() );
	config.options = CUDPP_OPTION_FORWARD | CUDPP_OPTION_EXCLUSIVE ;
	result = cudppPlan(&scanplan, config, *pwordsCount, 1, 0); 
	size_t keyWordsCount;
	unsigned int* w = (unsigned int*) wordsId.GetDevice();
	cudppCompact(scanplan, w, &keyWordsCount, w, w, len);
	cudaFree(d_odata);
	cudaFree(pwordsCount);

}

void Foo()
{
	WordFinder* finder = CreateWordFinder();
	FILE* f = fopen(".\\words.txt","rt");
	char* tmpBuf = new char[64];
	std::vector<std::string> words;
	while (!feof(f))
	{
		fgets(tmpBuf, 64, f);
		std::string word = tmpBuf;
		words.push_back(word);	
	}
	finder->AddWords( words );
	delete[] tmpBuf;
	TransitionsTable* table = finder->Generate();
	
	FileStruct* file = new FileStruct(".\\goog0.txt");
	char* text = file->GetHostBuffer();
	
	event_pair time;
	start_timer(&time);
	Word* findedWords = new Word[file->GetSize()];
	int host_count = host_FindAllWords(table->Table , text, findedWords);
	
	float host_time = stop_timer(&time, "CPU word finder");
	
	start_timer(&time);

	size_t size = file->GetSize();

	// setup execution parameters
    dim3 threads(512, 1);
    dim3 grid(size/512,1);
	

    // execute the kernel	
	Transition* device_table = (Transition*)GetDeviceMemory(table->Table, table->Size);
	check_cuda_error("Host to device Mem cpy:");
	Buffer device_wordsCountBuf(sizeof(int) * 2);
	int* pDeviceCount = (int*)device_wordsCountBuf.GetDevice();  
	Buffer device_findedWordsBuf(512 * sizeof(Word));
	Word* device_findedWords = (Word*)device_findedWordsBuf.GetDevice();
	char* device_text = file->GetDeviceBuffer();
	Buffer allWords(sizeof(int)*size/4);
	Buffer allWordsCount(sizeof(int));
	deviceFindAllWords(device_table, device_text, size, device_findedWords,  pDeviceCount,
		(int*)allWords.GetDevice(), (int*)allWordsCount.GetDevice());
	//device_FindAllWords<<< grid, threads >>>(device_table, device_text, size, device_findedWords,  pDeviceCount,
	//	allWords.GetDevice(), allWordsCount.GetDevice());

	int device_count = *((int*)device_wordsCountBuf.GetHost());
	Word* devicefindedWords = (Word*)device_findedWordsBuf.GetHost();
	cudaFree(device_table);
	check_cuda_error("CUDA:");
	//check_launch("CUDA word finder");
	float device_time = stop_timer(&time, "GPU word finder");
	
	Buffer result(512);
	
	sprintf((char*)result.GetHost(),"CPU version time: %f, Count: %d ; Device version time: %f, count %d; allWord count: %d ",
		host_time, host_count, device_time, device_count, allWordsCount.GetHost());
	device_WatchDebug<<< 1, 1 >>>((char*)result.GetDevice());

	delete[] findedWords;
	delete file;
	delete table;
}
