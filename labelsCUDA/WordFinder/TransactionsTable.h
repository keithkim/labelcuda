#pragma once

class TrunsactionsTable
{
public:
	Transition*  Table;
	int Size;

	TrunsactionsTable(size_t count)
	{
		Table = new Transition[count];
		Size = count * State.StateSize;
	}

	inline Transition GetTransaction(int id, char symbol)
	{
		//return Table[id * ElementSize + symbol];
		return GetState(id)[symbol];
	}
	inline Transition* GetState(int id)
	{
		return Table + id * State.StateSize;
	}

	~TrunsactionsTable()
	{
		if (Table != NULL)
		{
			delete Table;
		}
	}
};