using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WindowsFormsApp1.DTO
{
    public class Bill
    {
        public Bill(int id, DateTime? dateCheckIn,DateTime? dateCheckOut, int status, int discount =0, float totalPrice=0)
        {
            this.ID = id;
            this.DateCheckIn = dateCheckIn;
            this.DateCheckOut = dateCheckOut;
            this.Status = status;
            this.Discount = discount;
            this.TotalPice = totalPice;
        }
        public Bill(DataRow row)
        {
            this.ID = (int)row["id"];
            this.DateCheckIn = (DateTime?)row["CheckIn"];
            var CheckOutTemp = row["CheckOut"];
            if (CheckOutTemp.ToString() != "")
            {
                this.DateCheckOut = (DateTime?)CheckOutTemp;
                this.TotalPice = (float)Convert.ToSingle(row["totalPice"]);
            }
               
           
            this.Status = (int)row["status"];
            if (row["discount"].ToString() != "")
                this.Discount = (int)row["discount"];
        }
        private float totalPice;
        private int discount;
        private int status;
        private DateTime? dateCheckIn;
        private DateTime? dateCheckOut;
        private int iD;

        public int ID { get => iD; set => iD = value; }
        public DateTime? DateCheckOut { get => dateCheckOut; set => dateCheckOut = value; }
        public DateTime? DateCheckIn { get => dateCheckIn; set => dateCheckIn = value; }
        public int Status { get => status; set => status = value; }
        public int Discount { get => discount; set => discount = value; }
        public float TotalPice { get => totalPice; set => totalPice = value; }
    }
}
