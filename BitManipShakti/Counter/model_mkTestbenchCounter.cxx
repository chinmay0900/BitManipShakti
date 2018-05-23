/*
 * Generated by Bluespec Compiler, version 2017.07.A (build 1da80f1, 2017-07-21)
 * 
 * On Wed May 23 11:02:03 GMT 2018
 * 
 */
#include "bluesim_primitives.h"
#include "model_mkTestbenchCounter.h"

#include <cstdlib>
#include <time.h>
#include "bluesim_kernel_api.h"
#include "bs_vcd.h"
#include "bs_reset.h"


/* Constructor */
MODEL_mkTestbenchCounter::MODEL_mkTestbenchCounter()
{
  mkTestbenchCounter_instance = NULL;
}

/* Function for creating a new model */
void * new_MODEL_mkTestbenchCounter()
{
  MODEL_mkTestbenchCounter *model = new MODEL_mkTestbenchCounter();
  return (void *)(model);
}

/* Schedule functions */

static void schedule_posedge_CLK(tSimStateHdl simHdl, void *instance_ptr)
       {
	 MOD_mkTestbenchCounter &INST_top = *((MOD_mkTestbenchCounter *)(instance_ptr));
	 tUInt32 DEF_INST_top_DEF_x__h229;
	 INST_top.INST_counter.PORT_EN_load = (tUInt8)0u;
	 INST_top.INST_counter.DEF_WILL_FIRE_load = (tUInt8)0u;
	 DEF_INST_top_DEF_x__h229 = INST_top.INST_state.METH_read();
	 INST_top.DEF_CAN_FIRE_RL_done = DEF_INST_top_DEF_x__h229 == 2u;
	 INST_top.DEF_WILL_FIRE_RL_done = INST_top.DEF_CAN_FIRE_RL_done;
	 INST_top.INST_counter.METH_RDY_load();
	 INST_top.DEF_CAN_FIRE_RL_step0 = DEF_INST_top_DEF_x__h229 == 0u;
	 INST_top.DEF_WILL_FIRE_RL_step0 = INST_top.DEF_CAN_FIRE_RL_step0;
	 INST_top.DEF_CAN_FIRE_RL_step1 = DEF_INST_top_DEF_x__h229 == 1u;
	 INST_top.DEF_WILL_FIRE_RL_step1 = INST_top.DEF_CAN_FIRE_RL_step1;
	 if (INST_top.DEF_WILL_FIRE_RL_done)
	   INST_top.RL_done();
	 if (INST_top.DEF_WILL_FIRE_RL_step0)
	   INST_top.RL_step0();
	 if (INST_top.DEF_WILL_FIRE_RL_step1)
	   INST_top.RL_step1();
	 if (do_reset_ticks(simHdl))
	 {
	   INST_top.INST_counter.INST_value.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_state.rst_tick__clk__1((tUInt8)1u);
	 }
       };

/* Model creation/destruction functions */

void MODEL_mkTestbenchCounter::create_model(tSimStateHdl simHdl, bool master)
{
  sim_hdl = simHdl;
  init_reset_request_counters(sim_hdl);
  mkTestbenchCounter_instance = new MOD_mkTestbenchCounter(sim_hdl, "top", NULL);
  bk_get_or_define_clock(sim_hdl, "CLK");
  if (master)
  {
    bk_alter_clock(sim_hdl, bk_get_clock_by_name(sim_hdl, "CLK"), CLK_LOW, false, 0llu, 5llu, 5llu);
    bk_use_default_reset(sim_hdl);
  }
  bk_set_clock_event_fn(sim_hdl,
			bk_get_clock_by_name(sim_hdl, "CLK"),
			schedule_posedge_CLK,
			NULL,
			(tEdgeDirection)(POSEDGE));
  (mkTestbenchCounter_instance->INST_counter.set_clk_0)("CLK");
  (mkTestbenchCounter_instance->set_clk_0)("CLK");
}
void MODEL_mkTestbenchCounter::destroy_model()
{
  delete mkTestbenchCounter_instance;
  mkTestbenchCounter_instance = NULL;
}
void MODEL_mkTestbenchCounter::reset_model(bool asserted)
{
  (mkTestbenchCounter_instance->reset_RST_N)(asserted ? (tUInt8)0u : (tUInt8)1u);
}
void * MODEL_mkTestbenchCounter::get_instance()
{
  return mkTestbenchCounter_instance;
}

/* Fill in version numbers */
void MODEL_mkTestbenchCounter::get_version(unsigned int *year,
					   unsigned int *month,
					   char const **annotation,
					   char const **build)
{
  *year = 2017u;
  *month = 7u;
  *annotation = "A";
  *build = "1da80f1";
}

/* Get the model creation time */
time_t MODEL_mkTestbenchCounter::get_creation_time()
{
  
  /* Wed May 23 11:02:03 UTC 2018 */
  return 1527073323llu;
}

/* Control run-time licensing */
tUInt64 MODEL_mkTestbenchCounter::skip_license_check()
{
  return 0llu;
}

/* State dumping function */
void MODEL_mkTestbenchCounter::dump_state()
{
  (mkTestbenchCounter_instance->dump_state)(0u);
}

/* VCD dumping functions */
MOD_mkTestbenchCounter & mkTestbenchCounter_backing(tSimStateHdl simHdl)
{
  static MOD_mkTestbenchCounter *instance = NULL;
  if (instance == NULL)
  {
    vcd_set_backing_instance(simHdl, true);
    instance = new MOD_mkTestbenchCounter(simHdl, "top", NULL);
    vcd_set_backing_instance(simHdl, false);
  }
  return *instance;
}
void MODEL_mkTestbenchCounter::dump_VCD_defs()
{
  (mkTestbenchCounter_instance->dump_VCD_defs)(vcd_depth(sim_hdl));
}
void MODEL_mkTestbenchCounter::dump_VCD(tVCDDumpType dt)
{
  (mkTestbenchCounter_instance->dump_VCD)(dt,
					  vcd_depth(sim_hdl),
					  mkTestbenchCounter_backing(sim_hdl));
}
