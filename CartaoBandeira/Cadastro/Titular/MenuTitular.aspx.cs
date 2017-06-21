using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;

using System.Web.Services;
using System.Web.Script.Services;
using Newtonsoft.Json;

//using PortalCard.Lib.Util.UtilValidacao;
using WCFCadastroPessoa;

public partial class MenuTitular : System.Web.UI.Page
{

    #region Properties

    public static string CNPJFranqueado { get; set; }
    public static string UserName { get; set; }

    #endregion

    #region Services

    protected static CadastroPessoaClient CadastroService = null;

    #endregion

    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {
        VerificarSessao();
            
        if (!Page.IsPostBack)
        {
            if (Session["Operacao"] != null)
            {
                this.hdnOperacao.Value = Session["Operacao"].ToString();
                Session["Operacao"] = null;
            }

            if (Session["Mensagem"] != null)
            {
                this.hdnMensagem.Value = Session["Mensagem"].ToString();
                Session["Mensagem"] = null;
            }

            if (Session["NumeroCartao"] != null)
            {
                this.hdnNumeroCartao.Value = Session["NumeroCartao"].ToString();
                Session["NumeroCartao"] = null;
            }

            Session["LinkVoltar"] = null;
            Session["TipoPesquisa"] = null;
            Session["ValorPesquisa"] = null;

        }

    }

    #endregion

    #region WebMethods


    [WebMethod(EnableSession = true)]
    public static JsonResult ConsultaTitular(string valorPesquisa, string tipoPesquisa)
    {
        var ret = new JsonResult();

        try
        {
            var sessao = VerificarSessao();

            if (!sessao)
            {
                ret.Resposta = false;
                ret.Mensagem = "SessaoFinalizada";
                return ret;
            }

            HttpContext.Current.Session["ValorPesquisa"] = valorPesquisa;
            HttpContext.Current.Session["TipoPesquisa"] = tipoPesquisa;
            HttpContext.Current.Session["LinkVoltar"] = HttpContext.Current.Request.FilePath;

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);

            if (tipoPesquisa != "NOME")
                valorPesquisa = valorPesquisa.Replace(".", "").Replace("-", "").Replace("/","").Replace(" ", "");

            ret.Resultado = CadastroService.ObterTitular(valorPesquisa, tipoPesquisa);
            ret.Resposta = true;

        }
        catch (Exception ex)
        {
            ret.Erro = true;
            ret.Resposta = false;
            ret.Mensagem = ex.Message;
        }

        return ret;
        
    }

    #endregion

    #region Methods

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

        return (this.txtPesquisa.Text.Trim() != "");

    }

    #endregion

}

