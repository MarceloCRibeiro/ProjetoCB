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

public partial class Produto : System.Web.UI.Page
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
        Session["Operacao"] = "Incluir";

        VerificarSessao();

        if (!Page.IsPostBack)
        {
            var codConta = Request["conta"];

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);

            var titular = CadastroService.ObterTitular(codConta, "CONTA").FirstOrDefault();

            if (titular.PessoaFisica != null)
            {
                this.hdnUsuario.Value = "PF";

                this.lblCpfCnpj.Text = "CPF:";
                this.lbNome.Text = "Nome do Cliente Titular:";
                this.lblCpfCnpjTitular.Text = titular.PessoaFisica.CPF.Substring(0, 3) + '.' + titular.PessoaFisica.CPF.Substring(3, 3) + '.' + titular.PessoaFisica.CPF.Substring(6, 3) + "-" + titular.PessoaFisica.CPF.Substring(9, 2);
                this.lblNomeTitular.Text = titular.PessoaFisica.NomeCompleto;
                this.lblRenda.Text = "Renda Mensal:";
                this.txtRendaMensal.Text = string.Format("{0:n2}", titular.PessoaFisica.Renda);

                this.txtNomeCartao.Text = titular.Conta.ContaProduto.FirstOrDefault().Cartao.NomeCartao.ToUpper();

            }
            else
            {
                this.hdnUsuario.Value = "PJ";

                this.lblCpfCnpj.Text = "CNPJ:";
                this.lbNome.Text = "Nome do Cliente Empresa Titular:";
                this.lblCpfCnpjTitular.Text = titular.PessoaJuridica.CNPJPJ.Substring(0, 2) + "." + titular.PessoaJuridica.CNPJPJ.Substring(2, 3) + "." + titular.PessoaJuridica.CNPJPJ.Substring(5, 3) + "/" + titular.PessoaJuridica.CNPJPJ.Substring(8, 4) + "-" + titular.PessoaJuridica.CNPJPJ.Substring(12);
                this.lblNomeTitular.Text = titular.PessoaJuridica.NomeFantasia;
                this.lblRenda.Text = "Patrimônio Liquido:";
                this.txtRendaMensal.Text = string.Format("{0:n2}", titular.PessoaJuridica.PatrimonioLiquido);

                this.txtNomeCartao.Text = titular.Conta.ContaProduto.FirstOrDefault().Cartao.NomeCartao.ToUpper();

            }

            var limiteConta = titular.Conta.LimiteDaConta;
            var limiteProdutos = titular.Conta.ContaProduto.Where(s => s.CodStatusContaProduto != 3 && s.Cartao.CodStatusCartao != 3).Sum(s => s.LimiteProduto);

            this.txtLimiteConta.Text = string.Format("{0:n2}", limiteConta - limiteProdutos);
            
            List<string> produtos = new List<string>();
            foreach (var produto in titular.Conta.ContaProduto)
            {
                produtos.Add(produto.CodProduto.ToString());
            }

            this.hdnCodConta.Value = codConta;
            this.hdnListaProdutos.Value = JsonConvert.SerializeObject(produtos);

            string query = "";
            if (Session["ValorPesquisa"] != null && Session["TipoPesquisa"] != null)
                query = "?ValorPesquisa=" + Session["ValorPesquisa"].ToString() + "&TipoPesquisa=" + Session["TipoPesquisa"];

            string href = "MenuTitular.aspx";
            if (Session["LinkVoltar"] != null)
                href = Session["LinkVoltar"].ToString();

            this.btnVoltar.Attributes["href"] = href + query;

        }

    }

    protected void btnConfirmar_Click(object sender, EventArgs e)
    {
        bool retorno = false;
        string operacao = Session["Operacao"].ToString();
        string limites = this.hdnListaLimites.Value;

        CadastroService = new CadastroPessoaClient();
        CadastroService.SetCNPJFranquia(CNPJFranqueado);
        CadastroService.SetLogin(UserName);

        if (operacao == "Incluir")
        {
            JavaScriptSerializer json = new JavaScriptSerializer();
            var limite = JsonConvert.DeserializeObject<List<LimiteEnt>>(limites);

            #region ContaProduto

            var contaProduto = new ContaProdutoEnt();
            contaProduto.CodConta = Convert.ToInt32(GetRequest(Request.Form["hdnCodConta"]));
            contaProduto.CodProduto = Convert.ToInt32(Request.Form["ddlProduto"]);
            contaProduto.CNPJ = CNPJFranqueado;
            contaProduto.CodVencimento = Convert.ToInt32(Request.Form["ddlDiaVencimento"]);
            contaProduto.Senha = null;
            contaProduto.CodStatusContaProduto = 1; // ativo
            contaProduto.CodTipoBloqueio = 9; // ativo
            contaProduto.CodTipoOperacaoCartao = Convert.ToInt32(Request.Form["ddlTipoOperacaoCartao"]);
            if (!string.IsNullOrEmpty(Request.Form["txtLimiteProduto"]))
                contaProduto.LimiteProduto = Convert.ToDecimal(Request.Form["txtLimiteProduto"].Replace(".", ""));

            #endregion

            #region Cartao

            contaProduto.Cartao = new CartaoEnt();
            contaProduto.Cartao.CodConta = contaProduto.CodConta;
            contaProduto.Cartao.CodProduto = contaProduto.CodProduto;
            contaProduto.Cartao.NumeroCartao = GerarNumeroCartao();
            contaProduto.Cartao.CodAdicional = null;
            contaProduto.Cartao.CVC = null;
            contaProduto.Cartao.RangeCartao = Int32.Parse(contaProduto.Cartao.NumeroCartao.Substring(10, 3));
            contaProduto.Cartao.BIN = contaProduto.Cartao.NumeroCartao.Substring(0, 6);
            contaProduto.Cartao.NomeCartao = Request.Form["txtNomeCartao"];
            //contaProduto.Cartao.EmiteCartao = true;
            contaProduto.Cartao.CodTipoSegundaViaCartao = null;
            contaProduto.Cartao.CodStatusCartao = Convert.ToInt32(Request.Form["ddlStatusCartao"]);
            contaProduto.Cartao.DataVencimentoCartaoBandeira = DateTime.Parse(GetRequest(Request.Form["hdnDataVencimentoBandeira"]));
            contaProduto.Cartao.DataVencimentoCartaoEmissor = DateTime.Parse(GetRequest(Request.Form["hdnDataVencimentoEmissor"]));

            //contaProduto.Cartao.CodStatusCartao = 2;
            //contaProduto.Cartao.CodMotivoCartao = 2;

            contaProduto.Cartao.BloqExterior = Request.Form["ddlBloqueadoExterior"] == "1" ? true : false;
            if (contaProduto.Cartao.BloqExterior.Value)
            {
                contaProduto.Cartao.FaixaIniBloqExt = null;
                contaProduto.Cartao.FaixaFimBloqExt = null;
            }
            else
            {
                contaProduto.Cartao.FaixaIniBloqExt = DateTime.Parse(Request.Form["txtFaixaIniBloqExt"]);
                contaProduto.Cartao.FaixaFimBloqExt = DateTime.Parse(Request.Form["txtFaixaFimBloqExt"]);
            }
                
            #endregion

            #region Limites

            contaProduto.Cartao.Limites = limite;

            #endregion

            #region GrupoTarifa

            if (!string.IsNullOrEmpty(Request.Form["ddlGrupoTarifa"]))
            {
                contaProduto.GrupoTarifa = new GrupoTarifaEnt();
                contaProduto.GrupoTarifa.CodGrupoTarifa = Convert.ToInt32(Request.Form["ddlGrupoTarifa"]);
                if (!string.IsNullOrEmpty(Request.Form["txtVencimentoGrupoTarifario"]))
                    contaProduto.GrupoTarifa.DataVencimento = Convert.ToDateTime(Request.Form["txtVencimentoGrupoTarifario"]);
            }

            #endregion

            retorno = CadastroService.IncluirCartaoTitular(contaProduto);

            if (retorno)
            {
                Session["Operacao"] = "Sucesso";
                Session["Mensagem"] = "Cartão incluído com sucesso!";
                Session["NumeroCartao"] = contaProduto.Cartao.NumeroCartao.Substring(0, 4) + " XXXX XXXX " + contaProduto.Cartao.NumeroCartao.Substring(12);
                //Session["NumeroCartao"] = contaProduto.Cartao.NumeroCartao;

                string query = "";
                if (Session["ValorPesquisa"] != null && Session["TipoPesquisa"] != null)
                    query = "?ValorPesquisa=" + Session["ValorPesquisa"].ToString() + "&TipoPesquisa=" + Session["TipoPesquisa"];

                string href = "MenuTitular.aspx";
                if (Session["LinkVoltar"] != null)
                    href = Session["LinkVoltar"].ToString();

                Response.Redirect(href + query, false);
            }

        }
        
    }

    #endregion

    #region WebMethods

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterListaBandeira()
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

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);

            ret.Resultado = CadastroService.ObterListaBandeira();
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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterListaBanco()
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

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            
            ret.Resultado = CadastroService.ObterListaBanco();
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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterDadosVencimentoFatura()
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

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            ret.Resultado = CadastroService.ObterDadosVencimentoFatura();
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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterListaProduto(int codBandeira)
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

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            ret.Resultado = CadastroService.ObterListaProduto(codBandeira);
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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterDadosLimiteProduto(int codConta, int codProduto, int codAdicional)
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

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            ret.Resultado = CadastroService.ObterDadosLimiteProduto(codConta, codProduto, codAdicional);
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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterVencimentoEmissor()
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

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            ret.Resultado = CadastroService.ObterVencimentoEmissor();
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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterListaGrupoTarifa(int codProduto)
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

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            ret.Resultado = CadastroService.ObterListaGrupoTarifa(codProduto);
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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterListaTipoCartao()
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

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            ret.Resultado = CadastroService.ObterListaTipoCartao();
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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterDadosGrupoTarifa(int codGrupoTarifa)
    {
        var ret = new JsonResult();

        try
        {
            if (!VerificarSessao())
            {
                ret.Resposta = false;
                ret.Mensagem = "SessaoFinalizada";
                return ret;
            }

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            ret.Resultado = CadastroService.ObterDadosGrupoTarifa(codGrupoTarifa);
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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterListaStatusCartao()
    {
        var ret = new JsonResult();

        try
        {
            if (!VerificarSessao())
            {
                ret.Resposta = false;
                ret.Mensagem = "SessaoFinalizada";
                return ret;
            }

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            ret.Resultado = CadastroService.ObterListaStatusCartao();
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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterListaTipoBloqueioCartao()
    {
        var ret = new JsonResult();

        try
        {
            if (!VerificarSessao())
            {
                ret.Resposta = false;
                ret.Mensagem = "SessaoFinalizada";
                return ret;
            }

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            ret.Resultado = CadastroService.ObterListaTipoBloqueioCartao();
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

    public string GetRequest(string str)
    {
        str = Regex.Replace(str, @"[^\x20-\x7F]", "");
        return str;
    }

    private string GerarNumeroCartao()
    {
        string numCartao = "";
        Random random = new Random();
        numCartao = random.Next(1000, 9999).ToString() + random.Next(1000, 9999).ToString() + random.Next(1000, 9999).ToString() + random.Next(1000, 9999).ToString();
        
        //CadastroCartao.Cartao cartao = new CadastroCartao.Cartao();
        //CadastroCartao.FachadaCartao fachadaCartao = new CadastroCartao.FachadaCartao();

        //string numCartao = "";

        //if (Request.Url.Host.ToLower() != "localhost")
        //{
        //    cartao.CNPJFranqueado = CNPJFranqueado;
        //    cartao = fachadaCartao.GerarNumero(cartao);

        //    if (cartao != null && !string.IsNullOrEmpty(cartao.Resposta))
        //    {
        //        numCartao = cartao.Resposta.ToString();
        //    }
                
        //}
        //else
        //{
        //    Random random = new Random();
        //    numCartao = random.Next(1000, 9999).ToString() + random.Next(1000, 9999).ToString() + random.Next(1000, 9999).ToString() + random.Next(1000, 9999).ToString();
        //}

        return numCartao;

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

    #endregion

}

