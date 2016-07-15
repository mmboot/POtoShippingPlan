using System;
using System.Data;
using System.IO;
using System.Text;
using System.Windows.Forms;
using System.Data.SqlClient;
using System.Configuration;
using System.Linq;
using System.Data.OleDb;
using System.Drawing;

namespace POtoShippingPlan
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            label2.Text = "";
            label2.Visible = false;
        }

        private bool isDataGood()
        {
            bool ret = true;
            try
            {
                string connpo = ConfigurationManager.ConnectionStrings["connPO"].ConnectionString;
                OleDbConnection connPO = new OleDbConnection(connpo);
                connPO.Open();

                string cmd = "SELECT [Purchase Detail].* FROM [Purchase Detail]";
                OleDbCommand Cmd = new OleDbCommand(cmd, connPO);
                OleDbDataReader rdr = Cmd.ExecuteReader();
                DataTable dataTable = new DataTable("Purchase_Detail");
                dataTable.Load(rdr);


                String connectionString = ConfigurationManager.ConnectionStrings["conn"].ConnectionString;
                SqlConnection conn = new SqlConnection(connectionString);
                conn.Open();
                SqlCommand sqlCmd = new SqlCommand("TRUNCATE TABLE[dbo].[Purchase_Detail]", conn);
                sqlCmd.CommandType = CommandType.Text;
                sqlCmd.ExecuteNonQuery();

                SqlBulkCopy bulkCopy = new SqlBulkCopy(connectionString);

                foreach (DataColumn col in dataTable.Columns)
                {
                    bulkCopy.ColumnMappings.Add(col.ColumnName, col.ColumnName);
                }
                bulkCopy.BulkCopyTimeout = 600;
                bulkCopy.DestinationTableName = "[Purchase_Detail]";
                bulkCopy.WriteToServer(dataTable);


                rdr.Close();
                connPO.Close();
                conn.Close();
                bulkCopy.Close();
            }
            catch
            {
                ret = false;
                label2.Text = "RICS Data has a problem.\n Try unzipping a fresh batch to S:\\eCommerce\\RICSDATA";
                label2.Visible = true;
                label2.ForeColor = Color.Red;
            }
            return ret;
        }



        private StringBuilder SPHeader(String PONumber)
        {
            StringBuilder header = new StringBuilder();

            header.AppendLine("PlanName\tFBA" + PONumber);
            header.AppendLine("ShipToCountry\tUS");
            header.AppendLine("AddressName\tBoot World");
            header.AppendLine("AddressFieldOne\t7270 Trade Street");
            header.AppendLine("AddressFieldTwo\tSuite 101");
            header.AppendLine("AddressCity\tSan Diego");
            header.AppendLine("AddressCountryCode\tUS");
            header.AppendLine("AddressStateOrRegion\tCA");
            header.AppendLine("AddressPostalCode\t92121");
            header.AppendLine("AddressDistrict\t");
            header.AppendLine("");
            header.AppendLine("MerchantSKU\tQuantity");

            return header;
        }

        private void button1_Click_1(object sender, EventArgs e)
        {

            label2.Text = "";
            label2.Visible = false;


            if (isDataGood())
            { 

                String PONumber = textBox1.Text.Trim();
                StringBuilder SPFile = SPHeader(PONumber);            
                String path = @"S:\AMAZON\Shipping\ShippingPlanPrep\FBA" + PONumber + ".txt";
                SqlConnection conn = null;
                SqlDataReader rdr = null;

                String SKU = "";
                String Quantity = "";

                String connectionString = ConfigurationManager.ConnectionStrings["conn"].ConnectionString;


                var checkedButton = this.Controls.OfType<RadioButton>()
                                          .FirstOrDefault(r => r.Checked);

                String SizeStandard = checkedButton.Text.Trim();

                try
                {
                    conn = new SqlConnection(connectionString);
                    conn.Open();

                    SqlCommand cmd = new SqlCommand("[dbo].[GetPOLineItems]", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@PONumber", SqlDbType.VarChar);
                    cmd.Parameters.Add("@SizeStandard", SqlDbType.VarChar);
                    cmd.Parameters["@PONumber"].Value = PONumber;
                    cmd.Parameters["@SizeStandard"].Value = SizeStandard;
                    cmd.ExecuteNonQuery();
                
                    cmd = new SqlCommand("[dbo].[GetShippingPlanLineItem]", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    rdr = cmd.ExecuteReader();

                    while (rdr.Read())
                    {
                        SKU = rdr["SKU"].ToString();
                        Quantity = rdr["Quantity"].ToString();
                        SPFile.AppendLine(SKU + "\t" + Quantity);
                    }

                    if (File.Exists(path))
                    {
                        File.Delete(path); 
                    }

                    StreamWriter file = new StreamWriter(path, true);
                    file.Write(SPFile.ToString());
                    file.Close();
                
                }
                finally
                {
                    if (conn != null)
                    {
                        conn.Close();
                    }
                    if (rdr != null)
                    {
                        rdr.Close();
                    }
                }

                label2.Text = "Done with " + textBox1.Text;
                label2.Visible = true;
            }

        }

    }
}



