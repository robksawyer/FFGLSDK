#include "../Timer.h"
#include <mach/mach.h>
#include <mach/mach_time.h>

class OSXTimer :
public Timer
{
private:
  int g_firstTime;
  double g_conversion;
  uint64_t m_startTime;
public:
  
  
  
	OSXTimer()
		: m_startTime(0),
		g_conversion(0.0)
	{
		mach_timebase_info_data_t timebase;
		mach_timebase_info(&timebase);
		g_conversion = (1.0 / 1000000000.0) * ((double)timebase.numer / (double)timebase.denom );
		//start the timer now
		m_startTime = mach_absolute_time();
	}

	void Reset()
	{
		//restart the timer now
		m_startTime = mach_absolute_time();
	}

	double GetElapsedTime()
	{
		return 40.0;
		/*
		//whats the current time?
		uint64_t curTime = mach_absolute_time();

		uint64_t elapsed = curTime - m_startTime;

		return 40.0f;//g_conversion * (double)elapsed;
		*/
	}

	virtual ~OSXTimer()
	{}
};

Timer *Timer::New()
{
  return new OSXTimer();
}
