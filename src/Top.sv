module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

// please check out the working example in lab1 README (or Top_exmaple.sv) first

parameter IDLE   = 4'b0000, 
		//   PAUSE  = 4'b1xxx,
		  FINISH = 4'b0001,
		  RUN1   = 4'b0100,
		  RUN2   = 4'b0101,
		  RUN3   = 4'b0110,
		  RUN4   = 4'b0111;

logic [3:0]   state_comb, state_ff;
logic [25:0]  o_strout_comb, o_strout_ff;
logic [26:0]   counter_comb, counter_ff;
wire  poly;
// wire declaration
assign poly = o_strout_ff[0] ^ o_strout_ff[1] ^ o_strout_ff[5] ^ o_strout_ff[25];
assign o_random_out = o_strout_ff[3:0];	

// sequential block
always_ff@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		state_ff      <= IDLE;
		o_strout_ff   <= 0;
		counter_ff    <= 0;
	end
		
	else begin
		state_ff    <= state_comb;
		o_strout_ff <= o_strout_comb;
		counter_ff  <= counter_comb; 
	end
end
	
// combination block
always_comb begin

	state_comb = state_ff;
	o_strout_comb = o_strout_ff;
	counter_comb = counter_ff;
	
	casex(state_ff)
		IDLE: begin
			state_comb = (i_start) ? RUN1 : IDLE;
			counter_comb = (i_start) ? 27'd0 : counter_ff + 27'd1;
			o_strout_comb = (i_start) ? {counter_ff[14:5], counter_ff[15:6], 1'b0,counter_ff[4:0]} : o_strout_ff;
		end
		
		FINISH: begin
			state_comb = IDLE;
			o_strout_comb = {o_strout_ff[24:0], poly};
		end

		RUN1: begin
			state_comb = (counter_ff == 26'h3ff_fff8 ) ? RUN2 : ( (i_start) ? {1'b1, state_ff[2:0]} : state_ff);
			counter_comb = (i_start) ? counter_ff :  counter_ff + 27'd8;
			o_strout_comb = (i_start || counter_ff[24:3]) ? o_strout_ff : { o_strout_ff[24:0], poly };
		end

		RUN2: begin
			state_comb = (counter_ff == 26'h3ff_fffc ) ? RUN3 : ( (i_start) ? {1'b1, state_ff[2:0]} : state_ff);
			counter_comb = (i_start) ? counter_ff :  counter_ff + 27'd4;
			o_strout_comb = (i_start || counter_ff[24:2]) ? o_strout_ff : { o_strout_ff[24:0], poly };
		end

		RUN3: begin
			state_comb = (counter_ff == 26'h3ff_fffe ) ? RUN4 : ( (i_start) ? {1'b1, state_ff[2:0]} : state_ff);
			counter_comb = (i_start) ? counter_ff :  counter_ff + 27'd2;
			o_strout_comb = (i_start || counter_ff[24:1]) ? o_strout_ff : { o_strout_ff[24:0], poly };
		end

		RUN4: begin
			state_comb = (counter_ff == 26'h3ff_ffff ) ? FINISH : ( (i_start) ? {1'b1, state_ff[2:0]} : state_ff);
			counter_comb = (i_start) ? counter_ff :  counter_ff + 27'd1;
			o_strout_comb = (i_start || counter_ff[24:0]) ? o_strout_ff : { o_strout_ff[24:0], poly };
		end
		// pause states
		4'b1???: begin
			state_comb = (i_start) ? {1'b0, state_ff[2:0]} : state_ff;
		end
		default: begin
			
		end
	endcase
end



endmodule