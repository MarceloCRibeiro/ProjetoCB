using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Script.Serialization;
using Newtonsoft.Json;
using System.Text.RegularExpressions;

//using PortalCard.Lib.Util.UtilValidacao;
//using CadastroCartao = PortalCard.Lib.Cadastro.CadastroCartao;

using WCFCadastroPessoa;

public partial class Limite : System.Web.UI.Page
{

    #region Properties

    public static string CNPJFranqueado { get; set; }
    public static string UserName { get; set; }
    public static string Redirect { get; set; }

    #endregion

    #region Services

    protected static CadastroPessoaClient CadastroService = null;

    #endregion

    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {
        
        Session["Operacao"] = "Alterar";

        VerificarSessao();

        if (!Page.IsPostBack)
        {
            string query = "";
            if (Session["ValorPesquisa"] != null && Session["TipoPesquisa"] != null)
                query = "?ValorPesquisa=" + Session["ValorPesquisa"].ToString() + "&TipoPesquisa=" + Session["TipoPesquisa"];

            if (Session["LinkVoltar"] != null)
                Redirect = Session["LinkVoltar"].ToString();

            if (HttpContext.Current.Request.UrlReferrer != null && HttpContext.Current.Request.UrlReferrer.AbsoluteUri.Contains("Produto.aspx"))
                Redirect = HttpContext.Current.Request.UrlReferrer.AbsoluteUri;
            else
                Redirect = Redirect + query;
                
            this.btnVoltar.Attributes["href"] = Redirect;


            var codConta = Request["conta"];
    
            var titular = ObterTitular(codConta);

            if (titular.PessoaFisica != null)
            {
                this.lblCpfCnpj.Text = "CPF:";
                this.lbNome.Text = "Nome do Cliente Titular:";
                this.lblCpfCnpjTitular.Text = titular.PessoaFisica.CPF.Substring(0, 3) + '.' + titular.PessoaFisica.CPF.Substring(3, 3) + '.' + titular.PessoaFisica.CPF.Substring(6, 3) + "-" + titular.PessoaFisica.CPF.Substring(9, 2);
                this.lblNomeTitular.Text = titular.PessoaFisica.NomeCompleto;
                this.lblRenda.Text = "Renda Mensal:";
                this.txtRendaMensal.Text = string.Format("{0:n2}", titular.PessoaFisica.Renda);
            }
            else
            {
                this.lblCpfCnpj.Text = "CNPJ:";
                this.lbNome.Text = "Nome do Cliente Empresa Titular:";
                this.lblCpfCnpjTitular.Text = titular.PessoaJuridica.CNPJPJ.Substring(0, 2) + "." + titular.PessoaJuridica.CNPJPJ.Substring(2, 3) + "." + titular.PessoaJuridica.CNPJPJ.Substring(5, 3) + "/" + titular.PessoaJuridica.CNPJPJ.Substring(8, 4) + "-" + titular.PessoaJuridica.CNPJPJ.Substring(12);
                this.lblNomeTitular.Text = titular.PessoaJuridica.NomeFantasia;
                this.lblRenda.Text = "Patrimônio Liquido:";
                this.txtRendaMensal.Text = string.Format("{0:n2}", titular.PessoaJuridica.PatrimonioLiquido);
            }

            var limiteConta = titular.Conta.LimiteDaConta;
            var limiteProdutos = titular.Conta.ContaProduto.Where(s => s.CodStatusContaProduto != 3).Sum(s => s.LimiteProduto);

            this.txtLimiteConta.Text = string.Format("{0:n2}", limiteConta);
            //this.txtLimiteDisponivelConta.Text = string.Format("{0:n2}", limiteConta - limiteProdutos);

            this.hdnTitular.Value = JsonConvert.SerializeObject(titular);

            this.ddlNumeroCartaoTitular.Items.Insert(0, new ListItem("Selecione", ""));
            foreach (var contaProduto in titular.Conta.ContaProduto)
            {
                if (contaProduto.Cartao.CodStatusCartao != 3) // cancelado
                {
                    string text = string.Format("{0} - {1} - {2}", contaProduto.Cartao.NumeroCartao, contaProduto.Cartao.NomeBandeira, contaProduto.Cartao.NomeProduto, contaProduto.LimiteProduto);
                    this.ddlNumeroCartaoTitular.Items.Add(new ListItem(text, contaProduto.Cartao.CodCartao.ToString()));
                }
            }

        }

    }

    protected void btnConfirmar_Click(object sender, EventArgs e)
    {
        var titular = JsonConvert.DeserializeObject<TitularEnt>(GetRequest(Request.Form["hdnTitular"]));

        if (CadastroService.AtualizarLimites(titular.Conta))
        {
            Session["Operacao"] = "AlterarSucesso";
            Response.Redirect(Redirect, false);
        }
        else
        {
            Session["Operacao"] = "Erro";
            Response.Redirect(Redirect, false);
        }

    }

    #endregion

    #region WebMethods

    [WebMethod(EnableSession = true)]
    public static List<LimiteEnt> ObterDadosLimiteProduto(int codConta, int codProduto, int codAdicional)
    {
        try
        {
            CadastroPessoaClient CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);

            return CadastroService.ObterDadosLimiteProduto(codConta, codProduto, 0);

        }
        catch
        {
            throw;
        }

    }


    #endregion

    #region Methods

    private TitularEnt ObterTitular(string codConta)
    {
        CadastroService = new CadastroPessoaClient();
        CadastroService.SetCNPJFranquia(CNPJFranqueado);

        var titular = CadastroService.ObterTitular(codConta, "CONTA").FirstOrDefault();

        // por questão de segurança limpamos os dados desnecessários
        titular.DadosBancario = null;
        titular.Email = null;
        titular.Telefone = null;
        titular.Endereco = null;
        
        return titular;

    }

    private static bool VerificarSessao() // Verifica se sessão está ativa
    {
        if (HttpContext.Current.Session["VCGCFranq"] != null && HttpContext.Current.Session["UserName"] != null)
        {
            CNPJFranqueado = HttpContext.Current.Session["VCGCFranq"].ToString();
            UserName = HttpContext.Current.Session["UserName"].ToString();
        }
        else
        {
            if (HttpContext.Current.Request.Url.Host.ToLower() == "localhost")
            {
                HttpContext.Current.Session["VCGCFranq"] = "49345819849801";
                HttpContext.Current.Session["UserName"] = "ctgmateus";
                return true;
            }

            HttpContext.Current.Response.Redirect("../../SessaoFinalizada.aspx", false);
            return false;
        }

        return true;
    }

    private bool ValidarFiltro()
    {
        //Validacao valida = new Validacao();

        return true;

    }

    public string GetRequest(string str)
    {
        str = Regex.Replace(str, @"[^\x20-\x7F]", "");
        return str;
    }

    #endregion

}

