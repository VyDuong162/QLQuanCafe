using System.Data;

namespace WindowsFormsApp1.DTO
{
    public class Table
    {
        public Table(int id, string name, string status)
        {
            this.ID = id;
            this.Name = name;
            this.Status = status;
        }

        public Table(DataRow row)
        {
            this.ID = (int)row["id"];
            this.Name = row["name"].ToString();
            this.Status = row["status"].ToString();
        }

        private string status;
        private string name;
        private int iD;

        public string Status { get => status; set => status = value; }
        public string Name { get => name; set => name = value; }
        public int ID { get => iD; set => iD = value; }
    }
}