`ifndef TNOC_FABRIC_INVALID_DESTINATION_TEST_SVH
`define TNOC_FABRIC_INVALID_DESTINATION_TEST_SVH
class tnoc_fabric_invalid_destination_test_sequence extends tnoc_fabric_test_sequence_base;
  task body();
    foreach (p_sequencer.bfm_sequencer[i, j]) begin
      fork
        automatic int ii  = i;
        automatic int jj  = j;
        invalid_destination_test(p_sequencer.bfm_sequencer[ii][jj]);
      join_none
    end
    wait fork;
  endtask

  task invalid_destination_test(uvm_sequencer_base sequencer);
    for (int i = 0;i < 40;++i) begin
      tnoc_bfm_transmit_packet_sequence transmit_packet_sequence;
      `uvm_create_on(transmit_packet_sequence, sequencer)
      if (i >= 30) begin
        transmit_packet_sequence.c_default_invalid_destination.constraint_mode(0);
      end
      `uvm_rand_send_with(transmit_packet_sequence, {
        if (i < 10) {
          destination_id.x >= local::configuration.size_x;
          destination_id.y inside {[0:local::configuration.size_y-1]};
        }
        else if (i < 20) {
          destination_id.x inside {[0:local::configuration.size_x-1]};
          destination_id.y >= local::configuration.size_y;
        }
        else if (i < 30) {
          destination_id.x inside {[0:local::configuration.size_x-1]};
          destination_id.y inside {[0:local::configuration.size_y-1]};
          invalid_destination == 1;
        }
        else {
          invalid_destination                               ||
          (destination_id.x >= local::configuration.size_x) ||
          (destination_id.y >= local::configuration.size_y);
        }
      })
    end
  endtask

  `tue_object_default_constructor(tnoc_fabric_invalid_destination_test_sequence)
  `uvm_object_utils(tnoc_fabric_invalid_destination_test_sequence)
endclass

class tnoc_fabric_invalid_destination_test extends tnoc_fabric_test_base;
  function void start_of_simulation_phase(uvm_phase phase);
    set_default_sequence(sequencer, "main_phase", tnoc_fabric_invalid_destination_test_sequence::type_id::get());
  endfunction

  `tue_component_default_constructor(tnoc_fabric_invalid_destination_test)
  `uvm_component_utils(tnoc_fabric_invalid_destination_test)
endclass
`endif