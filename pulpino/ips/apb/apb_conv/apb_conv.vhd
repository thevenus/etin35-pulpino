-- Top module for apb_conv connecting controller and convolve unit 
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity apb_conv is
    port(
        -- APB BUS
        HCLK        : in std_logic;
        HRESETn     : IN STD_LOGIC;
        PADDR       : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        PWDATA      : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        PWRITE      : IN STD_LOGIC;
        PSEL        : IN STD_LOGIC;
        PENABLE     : IN STD_LOGIC;
        PRDATA      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        PREADY      : OUT STD_LOGIC;
        PSLVERR     : OUT STD_LOGIC
        );
end apb_conv;

architecture structural of apb_conv is

component conv_ctrl is
    port(
        HCLK        : in std_logic;
        HRESETn     : IN STD_LOGIC;
        PADDR       : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        PWDATA      : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        PWRITE      : IN STD_LOGIC;
        PSEL        : IN STD_LOGIC;
        PENABLE     : IN STD_LOGIC;
        PRDATA      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        PREADY      : OUT STD_LOGIC;
        PSLVERR     : OUT STD_LOGIC;
        conv_res_i      : in std_logic_vector(7 downto 0);
        conv_res_rdy_i  : in std_logic;
        conv_nrow_i     : in std_logic_vector(4 downto 0);
        conv_ncol_i     : in std_logic_vector(4 downto 0);
        conv_nchn_i     : in std_logic_vector(1 downto 0);
        input_window_o  : out std_logic_vector(74 downto 0);
        filter_o        : out std_logic_vector(74 downto 0);
        valid_data_o    : out std_logic
        );
end component;

component convolve is
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        valid_data: in std_logic;
        input_data : in std_logic_vector(74 downto 0);
        filter_data : in std_logic_vector(74 downto 0);
        result : out std_logic_vector(7 downto 0);
        ready : out std_logic;
        n_row : out std_logic_vector(4 downto 0);
        n_col : out std_logic_vector(4 downto 0);
        n_chn : out std_logic_vector(1 downto 0)
        );
end component;

signal Conv_res : std_logic_vector(7 downto 0);
signal Conv_res_rdy : std_logic; 
signal Conv_nrow : std_logic_vector(4 downto 0);
signal Conv_ncol : std_logic_vector(4 downto 0);
signal Conv_nchn : std_logic_vector(1 downto 0);
signal Input_window : std_logic_vector(74 downto 0);
signal Filter : std_logic_vector(74 downto 0);
signal Valid_data : std_logic;

begin

conv_ctrl_inst : conv_ctrl
    port map(
            HCLK => HCLK,
            HRESETn => HRESETn,
            PADDR => PADDR,
            PWDATA => PWDATA,
            PWRITE => PWRITE,
            PSEL => PSEL,
            PENABLE => PENABLE,
            PRDATA => PRDATA,
            PREADY => PREADY,
            PSLVERR => PSLVERR,
            conv_res_i => Conv_res,
            conv_res_rdy_i => Conv_res_rdy,
            conv_nrow_i => Conv_nrow,
            conv_ncol_i => Conv_ncol,
            conv_nchn_i => Conv_nchn,
            input_window_o => Input_window,
            filter_o => Filter,
            valid_data_o => Valid_data
            );

convolve_inst : convolve
    port map(
            clk => HCLK,
            rst_n => HRESETn,
            valid_data => Valid_data,
            input_data => Input_window,
            filter_data => Filter,
            result => Conv_res,
            ready => Conv_res_rdy,
            n_row => Conv_nrow,
            n_col => Conv_ncol,
            n_chn => Conv_nchn
            );

end structural; 
