using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WindowsFormsApp1.DTO
{
    public class Account
    {
        public Account(string username, string fullname, string password = null, int type =0)
        {
            this.UserName = username;
            this.FullName = fullname;
            this.PassWord = password;
            this.Type = type;
        }
        public Account(DataRow row)
        {
            this.UserName = row["UserName"].ToString();
            this.FullName = row["FullName"].ToString();
            this.PassWord = row["PassWord"].ToString();
            this.Type = (int)row["TYPE"];
        }

        private string userName;
        private string fullName;
        private string passWord;
        private int type;

        public string UserName { get => userName; set => userName = value; }
        public string FullName { get => fullName; set => fullName = value; }
        public string PassWord { get => passWord; set => passWord = value; }
        public int Type { get => type; set => type = value; }
    }
}
