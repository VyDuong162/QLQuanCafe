using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WindowsFormsApp1.DAO;
using WindowsFormsApp1.DTO;

namespace WindowsFormsApp1
{
    public partial class frmLogin : Form
    {
        public frmLogin()
        {
            InitializeComponent();
        }
        private void frmLogin_Load(object sender, EventArgs e)
        {
          
        }
        private void frmLogin_FormClosing(object sender, FormClosingEventArgs e)
        {
            DialogResult traloi;
            traloi = MessageBox.Show("Bạn chắc muốn thoát chương trình không?", "Trả lời", MessageBoxButtons.OKCancel, MessageBoxIcon.Question);
            if (traloi != DialogResult.OK)
                e.Cancel = true;
        }
        bool Login(string Username, string Password)
        {
            return AccountDAO.Instance.Login(Username, Password);
        }
        private void btnLogin_Click(object sender, EventArgs e)
        {
            string Username = txbUsername.Text;
            string Password = txbPassword.Text;
            if (Login(Username, Password))
            {
                Account loginAccount = AccountDAO.Instance.GetAccountByUserName(Username);
                frmTableManager f = new frmTableManager(loginAccount);
                this.Hide();
                f.ShowDialog();
                this.Show();
            }
            else
            {  
                MessageBox.Show("Tài khoản hoặc mật khẩu không trùng khớp","Thông báo");
                this.txbUsername.Focus();
            }
        }
        private void btnExit_Click(object sender, EventArgs e)
        {
           
            Application.Exit();

        }
     
    }
}
