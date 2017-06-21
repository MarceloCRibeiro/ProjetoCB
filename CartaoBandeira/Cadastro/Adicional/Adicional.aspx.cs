using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web;
using System.Web.Services;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Text.RegularExpressions;

//using CadastroCartao = PortalCard.Lib.Cadastro.CadastroCartao;
using WCFCadastroPessoa;

public partial class Adicional : System.Web.UI.Page
{

    #region Contructor

    public Adicional ()
	{
        Redirect = "MenuAdicional.aspx";
	}
    
    #endregion

    #region Properties

    public static string CNPJFranqueado { get; set; }
    public static string UserName { get; set; }
    public static string Redirect { get; set; }

    public static string Titular { get; set; }

    #endregion

    #region Services

    protected static CadastroPessoaClient CadastroService = null;

    #endregion

    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {
        VerificarSessao();

        string query = "";
        if (Session["ValorPesquisa"] != null && Session["TipoPesquisa"] != null)
            query = "?ValorPesquisa=" + Session["ValorPesquisa"].ToString() + "&TipoPesquisa=" + Session["TipoPesquisa"];

        Redirect = "MenuAdicional.aspx";
        if (Session["LinkVoltar"] != null)
            Redirect = Session["LinkVoltar"].ToString();

        Redirect = Redirect + query;
        this.btnVoltar.Attributes["href"] = Redirect;

        if (!Page.IsPostBack)
        {
            if (Request["operacao"] != null || Request["conta"] != null)
            {
                CadastroService = new CadastroPessoaClient();
                CadastroService.SetCNPJFranquia(CNPJFranqueado);

                TitularEnt titularEnt = null;

                var operacao = Request["operacao"];
                
                var titular = Request["titular"];
                var codConta = Request["conta"];

                this.hdnOperacao.Value = operacao;

                if (!string.IsNullOrEmpty(codConta))
                {
                    titularEnt = CadastroService.ObterTitular(codConta, "CONTA").FirstOrDefault();

                    if (titularEnt == null)
                        return;

                    if (titularEnt.PessoaFisica != null)
                        titular = titularEnt.PessoaFisica.CPF.Replace(".", "").Replace("-", "").Replace("/", "");
                    else
                        titular = titularEnt.PessoaJuridica.CNPJPJ.Replace(".", "").Replace("-", "").Replace("/", "");

                    

                }
                else if (!string.IsNullOrEmpty(titular)) {
                    titular = titular.Replace(".", "").Replace("-", "").Replace("/", "");

                    if (titular.Length == 11)
                        titularEnt = CadastroService.ObterTitular(titular, "CPF").FirstOrDefault();
                    else
                        titularEnt = CadastroService.ObterTitular(titular, "CNPJ").FirstOrDefault();

                    if (titularEnt == null)
                        return;

                }

                // filtramos somentes os cartões que não estejam cancelados
                titularEnt.Conta.ContaProduto = titularEnt.Conta.ContaProduto.Where(s => s.Cartao.CodStatusCartao != 3).ToList();

                foreach (var item in titularEnt.Conta.ContaProduto)
                {
                    if (item.Cartao.Adicional != null && item.Cartao.Adicional.Count > 0)
                    {
                        // filtramos somentes os cartões que não estejam cancelados
                        item.Cartao.Adicional = item.Cartao.Adicional.Where(s => item.Cartao.CodStatusCartao != 3).ToList();
                    }
                }

                if (titular.Length == 11)
                {
                    this.lblNome.Text = "Nome do Cliente Titular:";
                    this.hdnCpfTitular.Value = titular.ToString();

                    this.hdnUsuario.Value = "PF";

                }
                else
                {
                    this.lblNome.Text = "Nome do Cliente Empresa Titular:";
                    this.hdnCnpjTitular.Value = titular.ToString();
                    this.hdnUsuario.Value = "PJ";
                }

                if (operacao.ToLower() == "incluir")
                {
                    var nomeTitular = "";

                    if (titularEnt.PessoaFisica != null){
                        nomeTitular = titularEnt.PessoaFisica.NomeCompleto;
                    }
                    else {
                        nomeTitular = titularEnt.PessoaJuridica.NomeFantasia;
                    }
                    this.txtNomeTitular.Text = nomeTitular;
                    
                    //this.txtNumeroCartaoTitular.Text = cartaoTitular;
                    this.txtNumeroCartaoTitular.Visible = false;

                    //this.ddlNumeroCartaoTitular.DataTextField = "NumeroCartao";
                    //this.ddlNumeroCartaoTitular.DataValueField = "CodCartao";
                    //this.ddlNumeroCartaoTitular.DataSource = cartoesTitular;
                    //this.ddlNumeroCartaoTitular.DataBind();

                    this.hdnLimiteProduto.Value = "";
                    this.hdnCodProdutoCartao.Value = "";
                        
                    var limites = new Dictionary<int, string>();
                    var produtos = new Dictionary<int, int>();
                    var contas = new Dictionary<int, int>();

                    foreach (var item in titularEnt.Conta.ContaProduto)
                    {
                        if (item.Cartao.CodStatusCartao != 3) // cancelado
                        {
                            string text = string.Format("{0} - {1} - {2}", item.Cartao.NumeroCartao, item.Cartao.NomeBandeira, item.Cartao.NomeProduto, item.LimiteProduto);
                            ddlNumeroCartaoTitular.Items.Add(new ListItem(text, item.Cartao.CodCartao.ToString()));
                            limites[item.Cartao.CodCartao] = string.Format("{0:n2}", item.LimiteProduto);
                            produtos[item.Cartao.CodCartao] = item.CodProduto;
                            contas[item.Cartao.CodCartao] = item.CodConta;
                        }
                    }
                    this.ddlNumeroCartaoTitular.Items.Insert(0, new ListItem("Selecione",""));

                    this.hdnLimiteProduto.Value = JsonConvert.SerializeObject(limites);
                    this.hdnCodProdutoCartao.Value = JsonConvert.SerializeObject(produtos);
                    this.hdnCodConta.Value = JsonConvert.SerializeObject(contas);
                    this.ddlBloqueadoExterior.SelectedValue = "1";
                    //this.ddlStatusCartao.SelectedValue = "2";
                    //this.ddlTipoBloqueio.SelectedValue = "2";
                    this.lblStatusCartao.Text = "Bloqueado";
                    this.lblMotivo.Text = "Entrega";
                    this.divTipoBloqueio.Attributes.CssStyle.Clear();

                    this.txtLimiteProduto.Text = " - "; 

                    this.lblOperacao.Text = "Inclusão de Adicional";

                }
                else
                {
                    int idAdicional = Int32.Parse(Request["adicional"]);

                    CadastroService = new CadastroPessoaClient();
                    CadastroService.SetCNPJFranquia(CNPJFranqueado);

                    var adicional = CadastroService.ObterCartaoAdicional(idAdicional);

                    this.txtNomeTitular.Text = adicional.CartaoTitular.NomeCompleto;
                    this.txtNumeroCartaoTitular.Text = adicional.CartaoTitular.NumeroCartao;

                    this.hdnCpfAdicional.Value = adicional.CPFAdicional;
                    this.hdnCodAdicional.Value = adicional.CodAdicional.ToString();
                    this.hdnCodConta.Value = adicional.CodConta.ToString();
                    this.hdnCodCartaoAdicional.Value = adicional.CartaoAdicional.CodCartao.ToString();
                    this.hdnCodCartaoTitular.Value = adicional.CartaoTitular.CodCartao.ToString();
                    this.hdnCodProdutoCartao.Value = adicional.CartaoTitular.CodProduto.ToString();

                    this.txtNomeTitular.Text = adicional.CartaoTitular.NomeCompleto;
                    //this.txtNumeroCartaoTitular.Text = String.Format("{0}.XXXX.XXXX.{1} - {2} - {3}", adicional.CartaoTitular.NumeroCartao.Substring(0, 4), adicional.CartaoTitular.NumeroCartao.Substring(12, 4), adicional.CartaoTitular.NomeBandeira, adicional.CartaoTitular.NomeProduto);
                    this.txtNumeroCartaoTitular.Text = String.Format("{0} - {1} - {2}", adicional.CartaoTitular.NumeroCartao, adicional.CartaoTitular.NomeBandeira, adicional.CartaoTitular.NomeProduto);

                    this.txtNome.Text = adicional.Nome;
                    this.txtCpf.Text = adicional.CPFAdicional;
                    this.txtDataNascimento.Text = adicional.DataNascimento.ToString("dd/MM/yyyy");
                    this.ddlSexo.SelectedValue = adicional.CodGenero.ToString();

                    var lista = (List<ListaEnt>)ObterListaTipoParentesco().Resultado;
                    //this.ddlParentesco.Items.Add(new ListItem("Selecione", ""));
                    foreach (var item in lista)
                        this.ddlParentesco.Items.Add(new ListItem(item.Nome, item.Valor));
                    this.ddlParentesco.SelectedValue = adicional.CodParentesco.ToString();

                    lista = (List<ListaEnt>)ObterListaEscolaridade().Resultado;
                    this.ddlEscolaridade.Items.Add(new ListItem("Selecione", ""));
                    foreach (var item in lista)
                        this.ddlEscolaridade.Items.Add(new ListItem(item.Nome, item.Valor));
                    this.ddlEscolaridade.SelectedValue = adicional.CodGrauEscolaridade.ToString();

                    this.txtLimiteProduto.Text = string.Format("{0:n2}", adicional.CartaoTitular.LimiteProduto);
                    this.txtNomeCartao.Text = adicional.CartaoAdicional.NomeCartao;
                    //this.txtNumeroCartaoAdicional.Text = String.Format("{0}.XXXX.XXXX.{1}", adicional.CartaoAdicional.NumeroCartao.Substring(0, 4), adicional.CartaoAdicional.NumeroCartao.Substring(12, 4));
                    this.txtNumeroCartaoAdicional.Text = adicional.CartaoAdicional.NumeroCartao;

                    this.lblStatusCartao.Text = adicional.CartaoAdicional.StatusCartao;
                    this.lblMotivo.Text = adicional.CartaoAdicional.MotivoCartao;

                    //lista = (List<ListaEnt>)ObterListaStatusCartao().Resultado;
                    //this.ddlStatusCartao.Items.Add(new ListItem("Selecione", ""));
                    //foreach (var item in lista)
                    //    this.ddlStatusCartao.Items.Add(new ListItem(item.Nome, item.Valor));
                    //this.ddlStatusCartao.SelectedValue = adicional.CartaoAdicional.CodStatusCartao.ToString();

                    //lista = (List<ListaEnt>)ObterListaTipoBloqueioCartao().Resultado;
                    //this.ddlTipoBloqueio.Items.Add(new ListItem("Selecione", ""));
                    //foreach (var item in lista)
                    //    this.ddlTipoBloqueio.Items.Add(new ListItem(item.Nome, item.Valor));
                    
                    //if (this.ddlStatusCartao.SelectedItem.Text == "Bloqueado")
                    //{
                    //    this.divTipoBloqueio.Attributes.CssStyle.Clear();
                    //    this.ddlTipoBloqueio.SelectedValue = adicional.CartaoAdicional.CodTipoBloqueioCartao != null ? adicional.CartaoAdicional.CodTipoBloqueioCartao.Value.ToString() : "";
                    //}

                    if (adicional.CartaoAdicional.BloqExterior != null)
                    {

                        this.ddlBloqueadoExterior.SelectedValue = adicional.CartaoAdicional.BloqExterior.Value ? "1" : "0";

                        if (!adicional.CartaoAdicional.BloqExterior.Value)
                        {
                            this.txtFaixaIniBloqExt.Text = adicional.CartaoAdicional.FaixaIniBloqExt.Value.ToString("dd/MM/yyyy");
                            this.txtFaixaFimBloqExt.Text = adicional.CartaoAdicional.FaixaFimBloqExt.Value.ToString("dd/MM/yyyy");
                            this.divFaixaIniBloqExt.Attributes.CssStyle.Clear();
                            this.divFaixaFimBloqExt.Attributes.CssStyle.Clear();
                        }
                    }

                    this.ddlNumeroCartaoTitular.Visible = false;

                    if (operacao.ToLower() == "consultar")
                    {
                        this.lblOperacao.Text = "Consulta de Adicional";
                        this.txtNome.Attributes.Add("disabled", "disabled");
                        this.txtCpf.Attributes.Add("disabled", "disabled");
                        this.txtDataNascimento.Attributes.Add("disabled", "disabled");
                        this.ddlSexo.Attributes.Add("disabled", "disabled");
                        this.ddlParentesco.Attributes.Add("disabled", "disabled");
                        this.ddlEscolaridade.Attributes.Add("disabled", "disabled");
                        this.txtLimiteProduto.Attributes.Add("disabled", "disabled");
                        this.txtNomeCartao.Attributes.Add("disabled", "disabled");
                        this.txtNumeroCartaoAdicional.Attributes.Add("disabled", "disabled");
                        //this.ddlStatusCartao.Attributes.Add("disabled", "disabled");
                        //this.ddlTipoBloqueio.Attributes.Add("disabled", "disabled");
                        this.ddlBloqueadoExterior.Attributes.Add("disabled", "disabled");
                        this.txtFaixaIniBloqExt.Attributes.Add("disabled", "disabled");
                        this.txtFaixaFimBloqExt.Attributes.Add("disabled", "disabled");

                        this.btnConfirmar.Visible = false;

                    }
                    else if (operacao.ToLower() == "alterar")
                    {
                        this.lblOperacao.Text = "Alteração de Adicional";
                    }

                }

            }
        }

    }

    protected void btnVoltar_Click(object sender, EventArgs e)
    {
        Session["Operacao"] = null;
        Response.Redirect(Redirect, false);
    }

    protected void btnConfirmar_Click(object sender, EventArgs e)
    {
        try
        {
            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            CadastroService.SetLogin(UserName);

            var operacao = Request["operacao"];

            AdicionalEnt adicional = null;
            
            if (operacao.ToLower() == "incluir")
            {
                if (!ValidaInclusao())
                {
                    Session["Operacao"] = "Erro";
                    Response.Redirect(Redirect, false);
                    return;
                }

                adicional = new AdicionalEnt();
                adicional.CartaoAdicional = new CartaoEnt();

                //int CodCartaoTitular = Int32.Parse(this.hdnCodCartaoTitular.Value);
                int codCartaoTitular = Int32.Parse(Request.Form["ddlNumeroCartaoTitular"]);

                var limites = JsonConvert.DeserializeObject<List<LimiteEnt>>(GetRequest(Request.Form["hdnListaLimites"]));

                var cartaoTitular = CadastroService.ObterCartao(codCartaoTitular);

                //adicional.CodAdicional
                adicional.CPFTitular = cartaoTitular.CPF;
                adicional.CNPJPJ = cartaoTitular.CNPJPJ;
                adicional.CodConta = cartaoTitular.CodConta;
                adicional.CodLimite = null;
                adicional.SenhaAutorizacao = null;
                adicional.Nome = Request.Form["txtNome"];
                adicional.CPFAdicional = Request.Form["txtCpf"].Replace(".", "").Replace("-", "");
                adicional.CodGenero = Int32.Parse(Request.Form["ddlSexo"]);

                if (GetRequest(Request.Form["hdnUsuario"]) == "PF")
                {
                    adicional.CodGrauEscolaridade = Int32.Parse(Request.Form["ddlEscolaridade"]);
                    adicional.CodParentesco = Int32.Parse(Request.Form["ddlParentesco"]);
                }

                adicional.DataNascimento = DateTime.Parse(Request.Form["txtDataNascimento"]);
                adicional.CartaoAdicional.NumeroCartao = GerarNumeroCartao();
                adicional.CartaoAdicional.CodProduto = cartaoTitular.CodProduto;
                adicional.CartaoAdicional.CodConta = cartaoTitular.CodConta;
                // fixamos o como "Status Cartao = Bloqueado" e "Tipo Bloqueio = Entrega"
                //adicional.CartaoAdicional.CodStatusCartao = 2;
                //adicional.CartaoAdicional.CodTipoBloqueioCartao = 2;

                adicional.CartaoAdicional.BloqExterior = Request.Form["ddlBloqueadoExterior"] == "1" ? true : false;
                if (adicional.CartaoAdicional.BloqExterior.Value)
                {
                    adicional.CartaoAdicional.FaixaIniBloqExt = null;
                    adicional.CartaoAdicional.FaixaFimBloqExt = null;
                }
                else
                {
                    adicional.CartaoAdicional.FaixaIniBloqExt = DateTime.Parse(Request.Form["txtFaixaIniBloqExt"]);
                    adicional.CartaoAdicional.FaixaFimBloqExt = DateTime.Parse(Request.Form["txtFaixaFimBloqExt"]);
                }

                adicional.CartaoAdicional.CVC = null; ///TODO: VERIFICAR
                adicional.CartaoAdicional.RangeCartao = Int32.Parse(adicional.CartaoAdicional.NumeroCartao.Substring(10, 3));
                adicional.CartaoAdicional.BIN = adicional.CartaoAdicional.NumeroCartao.Substring(0, 6);
                adicional.CartaoAdicional.CNPJ = cartaoTitular.CNPJ;
                adicional.CartaoAdicional.NomeCartao = Request.Form["txtNomeCartao"];
                //adicional.CartaoAdicional.EmiteCartao = true; ///TODO: VERIFICAR
                ///adicional.CartaoAdicional.CodSegundaViaCartao = 1; ///TODO: VERIFICAR
                adicional.CartaoAdicional.CodTipoSegundaViaCartao = null;
                adicional.CartaoAdicional.Limites = limites;
                adicional.CartaoAdicional.DataVencimentoCartaoBandeira = cartaoTitular.DataVencimentoCartaoBandeira;
                adicional.CartaoAdicional.DataVencimentoCartaoEmissor = cartaoTitular.DataVencimentoCartaoEmissor;

                if (CadastroService.IncluirCartaoAdicional(adicional))
                {
                    Session["Operacao"] = "Sucesso";
                    Session["Mensagem"] = "Adicional incluído com sucesso!";
                    Session["NumeroCartao"] = adicional.CartaoAdicional.NumeroCartao.Substring(0, 4) + " XXXX XXXX " + adicional.CartaoAdicional.NumeroCartao.Substring(12);
                    //Session["NumeroCartao"] = adicional.CartaoAdicional.NumeroCartao;

                    string query = "";
                    if (Session["ValorPesquisa"] != null && Session["TipoPesquisa"] != null)
                        query = "?ValorPesquisa=" + Session["ValorPesquisa"].ToString() + "&TipoPesquisa=" + Session["TipoPesquisa"];

                    string href = "MenuAdicional.aspx";
                    if (Session["LinkVoltar"] != null)
                        href = Session["LinkVoltar"].ToString();

                    Response.Redirect(href + query, false);

                }
                else
                {
                    Session["Operacao"] = "Erro";
                    Response.Redirect(Redirect, false);
                }

            }
            else if (operacao.ToLower() == "alterar")
            {
                if (!ValidaAlteracao())
                {
                    Session["Operacao"] = "Erro";
                    Response.Redirect(Redirect, false);
                    return;
                }

                adicional = new AdicionalEnt();
                adicional.CartaoAdicional = new CartaoEnt();
                
                adicional.CodAdicional = Int32.Parse(GetRequest(Request.Form["hdnCodAdicional"]));
                //var limites = JsonConvert.DeserializeObject<List<LimiteEnt>>(this.hdnListaLimites.Value);

                adicional.CartaoAdicional.CodCartao = Int32.Parse(GetRequest(Request.Form["hdnCodCartaoAdicional"]));
                adicional.Nome = Request.Form["txtNome"];
                adicional.CPFAdicional = Request.Form["txtCpf"].Replace(".", "").Replace("-", "");
                adicional.DataNascimento = DateTime.Parse(Request.Form["txtDataNascimento"]);
                adicional.CodGenero = Int32.Parse(Request.Form["ddlSexo"]);

                if (GetRequest(Request.Form["hdnUsuario"]) == "PF")
                {
                    adicional.CodParentesco = Int32.Parse(Request.Form["ddlParentesco"]);
                    adicional.CodGrauEscolaridade = Int32.Parse(Request.Form["ddlEscolaridade"]);
                }

                adicional.CartaoAdicional.NomeCartao = Request.Form["txtNomeCartao"];
                
                //adicional.CartaoAdicional.CodStatusCartao = Int32.Parse(Request.Form["ddlStatusCartao"]);
                //adicional.CartaoAdicional.Limites = limites;
                //if (!string.IsNullOrEmpty(Request.Form["ddlTipoBloqueio"]))
                //    adicional.CartaoAdicional.CodTipoBloqueioCartao = Int32.Parse(Request.Form["ddlTipoBloqueio"]);
                //else
                //    adicional.CartaoAdicional.CodTipoBloqueioCartao = null;

                adicional.CartaoAdicional.BloqExterior = Request.Form["ddlBloqueadoExterior"] == "1" ? true : false;
                if (adicional.CartaoAdicional.BloqExterior.Value)
                {
                    adicional.CartaoAdicional.FaixaIniBloqExt = null;
                    adicional.CartaoAdicional.FaixaFimBloqExt = null;
                }
                else
                {
                    adicional.CartaoAdicional.FaixaIniBloqExt = DateTime.Parse(Request.Form["txtFaixaIniBloqExt"]);
                    adicional.CartaoAdicional.FaixaFimBloqExt = DateTime.Parse(Request.Form["txtFaixaFimBloqExt"]);
                }

                if (CadastroService.AtualizarCartaoAdicional(adicional))
                {
                    Session["Operacao"] = "Sucesso";
                    Session["Mensagem"] = "Adicional alterado com sucesso!";
                    Session["NumeroCartao"] = "";

                    Response.Redirect(Redirect, false);
                }
                else
                {
                    Session["Operacao"] = "Erro";
                    Response.Redirect(Redirect, false);
                }
                
            }
        }
        catch
        {
            Session["Operacao"] = "Erro";
            Response.Redirect(Redirect, false);
        }

    }

    #endregion

    #region WebMethods

    [WebMethod(EnableSession = true)]
    public static bool AdicionalExiste(int codCartaoTitular, string cpfAdicional)
    {
        try
        {
            bool ret = false;

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);

            var cartao = CadastroService.ObterCartao(codCartaoTitular);
            if (cartao != null && cartao.Adicional != null && cartao.Adicional.Count > 0)
            {
                var adicional = cartao.Adicional.Where(s => s.CPFAdicional == cpfAdicional).ToList();

                if (adicional != null && adicional.Count > 0)
                {
                    ret = true;
                }
            }

            return ret;

        }
        catch
        {
            throw;
        }
    }

    [WebMethod(EnableSession = true)]
    public static List<LimiteEnt> ObterDadosLimiteProduto(int codConta, int codProduto, int codAdicional)
    {
        try
        {
            CadastroPessoaClient CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);

            return CadastroService.ObterDadosLimiteProduto(codConta, codProduto, codAdicional);

        }
        catch
        {
            throw;
        }

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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterListaTipoParentesco()
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

            ret.Resultado = CadastroService.ObterListaTipoParentesco();
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
    public static JsonResult ObterListaEscolaridade()
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

            ret.Resultado = CadastroService.ObterListaEscolaridade();
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

        //try
        //{
        //    if (Request.Url.Host.ToLower() != "localhost")
        //    {
        //        cartao.CNPJFranqueado = CNPJFranqueado;
        //        cartao = fachadaCartao.GerarNumero(cartao);

        //        if (cartao != null)
        //        {
        //            numCartao = cartao.Resposta.ToString();
        //        }
        //    }
        //    else
        //    {
        //        Random random = new Random();
        //        numCartao = random.Next(1000, 9999).ToString() + random.Next(1000, 9999).ToString() + random.Next(1000, 9999).ToString() + random.Next(1000, 9999).ToString(); 
        //    }

        //}
        //catch(Exception ex) 
        //{
        //    var m = ex.Message;
        //}

        return numCartao;
        
    }

    private bool ValidaInclusao()
    {
        try
        {
            if (string.IsNullOrEmpty(Request.Form["ddlNumeroCartaoTitular"]))
                return false;

            if (string.IsNullOrEmpty(Request.Form["hdnListaLimites"]))
                return false;

            if (string.IsNullOrEmpty(Request.Form["ddlSexo"]))
                return false;

            //if (string.IsNullOrEmpty(Request.Form["ddlEscolaridade"]))
            //    return false;

            //if (string.IsNullOrEmpty(Request.Form["ddlParentesco"]))
            //    return false;

            if (string.IsNullOrEmpty(Request.Form["txtDataNascimento"]))
                return false;

            if (string.IsNullOrEmpty(Request.Form["ddlBloqueadoExterior"]))
                return false;

            if (Request.Form["ddlBloqueadoExterior"] == "0")
            {
                if (string.IsNullOrEmpty(Request.Form["txtFaixaIniBloqExt"]))
                    return false;

                if (string.IsNullOrEmpty(Request.Form["txtFaixaFimBloqExt"]))
                    return false;
            }

            if (string.IsNullOrEmpty(Request.Form["txtNomeCartao"]))
                return false;

            return true;

        }
        catch
        {
            return false;
        }

    }

    private bool ValidaAlteracao()
    {
        try
        {
            if (string.IsNullOrEmpty(Request.Form["hdnCodAdicional"]))
                return false;

            if (string.IsNullOrEmpty(Request.Form["hdnCodCartaoAdicional"]))
                return false;

            if (string.IsNullOrEmpty(Request.Form["txtNome"]))
                return false;

            if (string.IsNullOrEmpty(Request.Form["txtCpf"]))
                return false;

            if (string.IsNullOrEmpty(Request.Form["txtDataNascimento"]))
                return false;

            if (string.IsNullOrEmpty(Request.Form["txtNomeCartao"]))
                return false;

            if (string.IsNullOrEmpty(Request.Form["ddlBloqueadoExterior"]))
                return false;

            if (Request.Form["ddlBloqueadoExterior"] == "0")
            {
                if (string.IsNullOrEmpty(Request.Form["txtFaixaIniBloqExt"]))
                    return false;

                if (string.IsNullOrEmpty(Request.Form["txtFaixaFimBloqExt"]))
                    return false;
            }

            if (string.IsNullOrEmpty(Request.Form["txtNomeCartao"]))
                return false;

            return true;
        }
        catch
        {
            return false;
        }
    }

    #endregion

}

