using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Script.Serialization;
using Newtonsoft.Json;
using System.Text;
using System.Text.RegularExpressions;

//using CadastroCartao = PortalCard.Lib.Cadastro.CadastroCartao;
using WCFCadastroPessoa;

public partial class Titular : System.Web.UI.Page
{

    #region Properties

    public static string CNPJFranqueado { get; set; }
    public static string UserName { get; set; }

    public static string Usuario { get; set; }

    #endregion

    #region Services

    protected static CadastroPessoaClient CadastroService = null;

    #endregion

    #region Events

    protected void Page_Load(object sender, EventArgs e)
    {
        VerificarSessao();

        if (!string.IsNullOrEmpty(Request["conta"]))
        {
            Session["Operacao"] = "Alterar";
            
            var codConta = Request["conta"];

            var titular = ObterTitular(codConta);

            if (titular != null)
            {
                if (titular.PessoaJuridica != null)
                    Usuario = "PJ";
                else
                    Usuario = "PF";
            }

            this.hdnTitular.Value = JsonConvert.SerializeObject(titular);

        }
        else
        {
            Session["Operacao"] = "Incluir";

            if (Request["usuario"] != null && Request["usuario"].ToLower() == "pj")
                Usuario = "PJ";
            else
                Usuario = "PF";
        }

        string query = "";
        if (Session["ValorPesquisa"] != null && Session["TipoPesquisa"] != null)
            query = "?ValorPesquisa=" + Session["ValorPesquisa"].ToString() + "&TipoPesquisa=" + Session["TipoPesquisa"];

        string href = "MenuTitular.aspx";
        if (Session["LinkVoltar"] != null)
            href = Session["LinkVoltar"].ToString();

        this.btnVoltar.Attributes["href"] = href + query;

    }

    protected void btnConfirmar_Click(object sender, EventArgs e)
    {
        bool retorno = false;
        string operacao = Session["Operacao"].ToString();
                
        CadastroService = new CadastroPessoaClient();
        CadastroService.SetCNPJFranquia(CNPJFranqueado);
        CadastroService.SetLogin(UserName);

        if (operacao == "Incluir")
        {
            string emails = this.hdnListaEmails.Value;
            string tels = this.hdnListaTelefones.Value;
            string ends = this.hdnListaEnderecos.Value;
            string limites = this.hdnListaLimites.Value;
            string responsaveis = this.hdnListaResponsaveis.Value;

            TitularEnt titular = new TitularEnt();
            titular.DadosBancario = new DadosBancariosEnt();
            titular.Conta = new ContaEnt();
            titular.Conta.ContaProduto = new List<ContaProdutoEnt>();
            titular.Email = new List<EmailEnt>();
            titular.Telefone = new List<TelefoneEnt>();
            titular.Endereco = new List<EnderecoEnt>();
            
            JavaScriptSerializer json = new JavaScriptSerializer();
            var email = JsonConvert.DeserializeObject<List<EmailEnt>>(emails);
            var telefone = JsonConvert.DeserializeObject<List<TelefoneEnt>>(tels);
            var endereco = JsonConvert.DeserializeObject<List<EnderecoEnt>>(ends);
            var limite = JsonConvert.DeserializeObject<List<LimiteEnt>>(limites);
            var responsavel = JsonConvert.DeserializeObject<List<ResponsavelEnt>>(responsaveis);

            if (Usuario == "PF")
            {
                #region PessoaFisica

                titular.PessoaFisica = new PessoaFisicaEnt();

                if (!String.IsNullOrEmpty(Request.Form["txtCpf"]))
                    titular.PessoaFisica.CPF = txtCpf.Text;
                if (!String.IsNullOrEmpty(CNPJFranqueado))
                    titular.PessoaFisica.CNPJ = CNPJFranqueado;
                if (!String.IsNullOrEmpty(Request.Form["txtNomeUsu"]))
                    titular.PessoaFisica.NomeCompleto = Request.Form["txtNomeUsu"];
                if (!String.IsNullOrEmpty(Request.Form["txtRendaMensal"]))
                    titular.PessoaFisica.Renda = Convert.ToDecimal(Request.Form["txtRendaMensal"].Replace(".", ""));
                if (!String.IsNullOrEmpty(Request.Form["txtIdentidade"]))
                    titular.PessoaFisica.Identidade = Request.Form["txtIdentidade"];
                if (!String.IsNullOrEmpty(Request.Form["txtOrgaoEmissor"]))
                    titular.PessoaFisica.OrgaoExpedidor = Request.Form["txtOrgaoEmissor"];
                if (!String.IsNullOrEmpty(Request.Form["ddlUfOrgaoEmissor"]))
                    titular.PessoaFisica.UFOrgaoEmissor = Request.Form["ddlUfOrgaoEmissor"];
                if (!String.IsNullOrEmpty(Request.Form["txtPai"]))
                    titular.PessoaFisica.NomePai = Request.Form["txtPai"];
                if (!String.IsNullOrEmpty(Request.Form["txtMae"]))
                    titular.PessoaFisica.NomeMae = Request.Form["txtMae"];
                if (!String.IsNullOrEmpty(Request.Form["ddlEstadoCivil"]))
                    titular.PessoaFisica.CodEstadoCivil = Convert.ToInt32(Request.Form["ddlEstadoCivil"]);
                if (!String.IsNullOrEmpty(Request.Form["txtDtNascimento"]))
                    titular.PessoaFisica.DataNasc = Convert.ToDateTime(Request.Form["txtDtNascimento"]);
                if (!String.IsNullOrEmpty(Request.Form["ddlEscolaridade"]))
                    titular.PessoaFisica.CodEscolaridade = Convert.ToInt32(Request.Form["ddlEscolaridade"]);
                if (!String.IsNullOrEmpty(Request.Form["ddlSexo"]))
                    titular.PessoaFisica.CodSexo = Convert.ToInt32(Request.Form["ddlSexo"]);
                if (!String.IsNullOrEmpty(txtConjuge.Text))
                    titular.PessoaFisica.Conjuge = txtConjuge.Text;
                if (!String.IsNullOrEmpty(Request.Form["ddlProfissao"]))
                    titular.PessoaFisica.CodProfissao = Convert.ToInt32(Request.Form["ddlProfissao"]);

                #endregion
            }
            else
            {
                #region PessoaJuridica

                titular.PessoaJuridica = new PessoaJuridicaEnt();
                titular.PessoaJuridica.Responsavel = new List<ResponsavelEnt>();
                titular.PessoaJuridica.Responsavel = responsavel;

                if (!String.IsNullOrEmpty(Request.Form["txtCnpj"]))
                    titular.PessoaJuridica.CNPJPJ = txtCnpj.Text;
                if (!String.IsNullOrEmpty(CNPJFranqueado))
                    titular.PessoaJuridica.CNPJ = CNPJFranqueado;
                if (!String.IsNullOrEmpty(Request.Form["txtRazaoSocial"]))
                    titular.PessoaJuridica.RazaoSocial = Request.Form["txtRazaoSocial"];

                if (!String.IsNullOrEmpty(Request.Form["txtNomeFantasia"]))
                    titular.PessoaJuridica.NomeFantasia = Request.Form["txtNomeFantasia"];
                if (!String.IsNullOrEmpty(Request.Form["txtInscMunicipal"]))
                    titular.PessoaJuridica.InscrMunicipal = Request.Form["txtInscMunicipal"];
                if (!String.IsNullOrEmpty(Request.Form["txtInscEstadual"]))
                    titular.PessoaJuridica.InscrEstadual = Request.Form["txtInscEstadual"];
                if (!String.IsNullOrEmpty(Request.Form["txtDataFundacao"]))
                    titular.PessoaJuridica.DataFundacao = DateTime.Parse(Request.Form["txtDataFundacao"]);
                
                if (!String.IsNullOrEmpty(Request.Form["txtRendaMensal"]))
                    titular.PessoaJuridica.PatrimonioLiquido = Convert.ToDecimal(Request.Form["txtRendaMensal"].Replace(".", ""));


                #endregion
            }

            #region Dados Bancarios

            titular.DadosBancario.Ativo = true;
            titular.DadosBancario.DebitoEmConta = false;

            if (Request.Form["ddlDebAutomatico"] == "1")
            {
                titular.DadosBancario.DebitoEmConta = true;

                if (!String.IsNullOrEmpty(Request.Form["ddlBanco"]))
                    titular.DadosBancario.CodBanco = Request.Form["ddlBanco"];
                if (!String.IsNullOrEmpty(Request.Form["txtContaCorrente"]))
                    titular.DadosBancario.ContaCorrente = Request.Form["txtContaCorrente"];
                if (!String.IsNullOrEmpty(Request.Form["txtContaCorrenteDv"]))
                    titular.DadosBancario.DigCC = Request.Form["txtContaCorrenteDv"];
                if (!String.IsNullOrEmpty(Request.Form["txtAgencia"]))
                    titular.DadosBancario.Agencia = Request.Form["txtAgencia"];
                if (!String.IsNullOrEmpty(Request.Form["txtAgenciaDv"]))
                    titular.DadosBancario.DigAg = Request.Form["txtAgenciaDv"];

            }
            #endregion

            #region Conta

            if (!String.IsNullOrEmpty(Request.Form["txtLimiteConta"]))
                titular.Conta.LimiteDaConta = Convert.ToDecimal(Request.Form["txtLimiteConta"].Replace(".", ""));

            titular.Conta.CodStatusConta = 1; // ativo
            titular.Conta.CodTipoBloqueioConta = 9; // ativo
            titular.Conta.Observacao = "";

            #endregion

            #region ContaProduto

            var titularContaProduto = new ContaProdutoEnt();
            //titular.ContaProduto.CodProduto = Convert.ToInt32(ddlProduto.SelectedValue);
            titularContaProduto.CodProduto = Convert.ToInt32(Request.Form["ddlProduto"]);
            //titular.ContaProduto.CodVencimento = Convert.ToInt32(ddlDiaVencimento.SelectedValue);
            titularContaProduto.CodVencimento = Convert.ToInt32(Request.Form["ddlDiaVencimento"]);
            titularContaProduto.Senha = null;
            titularContaProduto.CodStatusContaProduto = 1; // ativo
            titularContaProduto.CodTipoBloqueio = 9; // ativo
            titularContaProduto.CodTipoOperacaoCartao = Convert.ToInt32(Request.Form["ddlTipoOperacaoCartao"]);

            if (!String.IsNullOrEmpty(Request.Form["txtLimiteProduto"]))
                titularContaProduto.LimiteProduto = Convert.ToDecimal(Request.Form["txtLimiteProduto"].Replace(".", ""));

            titular.Conta.ContaProduto.Add(titularContaProduto);

            #endregion

            #region Cartao

            var titularCartao = new CartaoEnt();
            titularCartao.NumeroCartao = GerarNumeroCartao();
            titularCartao.CodAdicional = null;
            titularCartao.CVC = null;
            titularCartao.RangeCartao = Int32.Parse(titularCartao.NumeroCartao.Substring(10, 3));
            titularCartao.BIN = titularCartao.NumeroCartao.Substring(0, 6);
            if (!String.IsNullOrEmpty(Request.Form["txtNomeCartao"]))
                titularCartao.NomeCartao = Request.Form["txtNomeCartao"];
            //titularCartao.EmiteCartao = true;
            titularCartao.CodTipoSegundaViaCartao = null;
            titularCartao.CodStatusCartao = Convert.ToInt32(Request.Form["ddlStatusCartao"]);
            titularCartao.DataVencimentoCartaoBandeira = Convert.ToDateTime(GetRequest(Request.Form["hdnDataVencimentoBandeira"]));
            titularCartao.DataVencimentoCartaoEmissor = Convert.ToDateTime(GetRequest(Request.Form["hdnDataVencimentoEmissor"]));

            //titularCartao.CodStatusCartao = 2;
            //titularCartao.CodMotivoCartao = 2;

            titularCartao.BloqExterior = Request.Form["ddlBloqueadoExterior"] == "1" ? true : false;
            if (titularCartao.BloqExterior.Value)
            {
                titularCartao.FaixaIniBloqExt = null;
                titularCartao.FaixaFimBloqExt = null;
            }
            else
            {
                titularCartao.FaixaIniBloqExt = DateTime.Parse(Request.Form["txtFaixaIniBloqExt"]);
                titularCartao.FaixaFimBloqExt = DateTime.Parse(Request.Form["txtFaixaFimBloqExt"]);
            }
            titular.Conta.ContaProduto.FirstOrDefault().Cartao = titularCartao;

            #endregion

            #region Limites

            if (limite != null && limite.Count > 0)
            {
                titular.Conta.ContaProduto.FirstOrDefault().Cartao.Limites = limite;
            }

            #endregion

            #region GrupoTarifa

            if (!string.IsNullOrEmpty(Request.Form["ddlGrupoTarifa"]))
            {
                titular.Conta.ContaProduto.FirstOrDefault().GrupoTarifa = new GrupoTarifaEnt();
                titular.Conta.ContaProduto.FirstOrDefault().GrupoTarifa.CodGrupoTarifa = Convert.ToInt32(Request.Form["ddlGrupoTarifa"]);
                if (Request.Form["txtVencimentoGrupoTarifario"] != "")
                    titular.Conta.ContaProduto.FirstOrDefault().GrupoTarifa.DataVencimento = Convert.ToDateTime(Request.Form["txtVencimentoGrupoTarifario"]);
            }

            #endregion

            #region Email

            if (email.Count > 0)
                titular.Email = email;

            #endregion

            #region Telefone

            if (telefone.Count > 0)
                titular.Telefone = telefone;

            #endregion

            #region Endereco

            if (endereco.Count > 0)
                titular.Endereco = endereco;

            #endregion

            retorno = CadastroService.IncluirClienteCartaoTitular(titular);

            if (retorno)
            {
                Session["Operacao"] = "Sucesso";
                Session["Mensagem"] = "Cliente cadastrado com sucesso!";
                Session["NumeroCartao"] = titularCartao.NumeroCartao.Substring(0, 4) + " XXXX XXXX " + titularCartao.NumeroCartao.Substring(12);
                //Session["NumeroCartao"] = titularCartao.NumeroCartao;

                string query = "";
                if (Session["ValorPesquisa"] != null && Session["TipoPesquisa"] != null)
                    query = "?ValorPesquisa=" + Session["ValorPesquisa"].ToString() + "&TipoPesquisa=" + Session["TipoPesquisa"];

                string href = "MenuTitular.aspx";
                if (Session["LinkVoltar"] != null)
                    href = Session["LinkVoltar"].ToString();

                Response.Redirect(href + query, false);

            }

        }
        else if (operacao == "Alterar")
        {
            string emails = this.hdnListaEmails.Value;
            string tels = this.hdnListaTelefones.Value;
            string ends = this.hdnListaEnderecos.Value;
            string responsaveis = this.hdnListaResponsaveis.Value;

            TitularEnt titular = new TitularEnt();
            titular.Email = new List<EmailEnt>();
            titular.Telefone = new List<TelefoneEnt>();
            titular.Endereco = new List<EnderecoEnt>();

            JavaScriptSerializer json = new JavaScriptSerializer();
            var email = JsonConvert.DeserializeObject<List<EmailEnt>>(emails);
            var telefone = JsonConvert.DeserializeObject<List<TelefoneEnt>>(tels);
            var endereco = JsonConvert.DeserializeObject<List<EnderecoEnt>>(ends);
            var responsavel = JsonConvert.DeserializeObject<List<ResponsavelEnt>>(responsaveis);

            if (Usuario == "PF")
            {
                #region PessoaFisica

                titular.PessoaFisica = new PessoaFisicaEnt();

                if (!String.IsNullOrEmpty(Request.Form["txtCpf"]))
                    titular.PessoaFisica.CPF = txtCpf.Text;
                if (!String.IsNullOrEmpty(CNPJFranqueado))
                    titular.PessoaFisica.CNPJ = CNPJFranqueado;
                if (!String.IsNullOrEmpty(Request.Form["txtNomeUsu"]))
                    titular.PessoaFisica.NomeCompleto = Request.Form["txtNomeUsu"];
                if (!String.IsNullOrEmpty(Request.Form["txtRendaMensal"]))
                    titular.PessoaFisica.Renda = Convert.ToDecimal(Request.Form["txtRendaMensal"].Replace(".", ""));
                if (!String.IsNullOrEmpty(Request.Form["txtIdentidade"]))
                    titular.PessoaFisica.Identidade = Request.Form["txtIdentidade"];
                if (!String.IsNullOrEmpty(Request.Form["txtOrgaoEmissor"]))
                    titular.PessoaFisica.OrgaoExpedidor = Request.Form["txtOrgaoEmissor"];
                if (!String.IsNullOrEmpty(Request.Form["ddlUfOrgaoEmissor"]))
                    titular.PessoaFisica.UFOrgaoEmissor = Request.Form["ddlUfOrgaoEmissor"];
                if (!String.IsNullOrEmpty(Request.Form["txtPai"]))
                    titular.PessoaFisica.NomePai = Request.Form["txtPai"];
                if (!String.IsNullOrEmpty(Request.Form["txtMae"]))
                    titular.PessoaFisica.NomeMae = Request.Form["txtMae"];
                if (!String.IsNullOrEmpty(Request.Form["ddlEstadoCivil"]))
                    titular.PessoaFisica.CodEstadoCivil = Convert.ToInt32(Request.Form["ddlEstadoCivil"]);
                if (!String.IsNullOrEmpty(Request.Form["txtDtNascimento"]))
                    titular.PessoaFisica.DataNasc = Convert.ToDateTime(Request.Form["txtDtNascimento"]);
                if (!String.IsNullOrEmpty(Request.Form["ddlEscolaridade"]))
                    titular.PessoaFisica.CodEscolaridade = Convert.ToInt32(Request.Form["ddlEscolaridade"]);
                if (!String.IsNullOrEmpty(Request.Form["ddlSexo"]))
                    titular.PessoaFisica.CodSexo = Convert.ToInt32(Request.Form["ddlSexo"]);
                if (!String.IsNullOrEmpty(txtConjuge.Text))
                    titular.PessoaFisica.Conjuge = txtConjuge.Text;
                if (!String.IsNullOrEmpty(Request.Form["ddlProfissao"]))
                    titular.PessoaFisica.CodProfissao = Convert.ToInt32(Request.Form["ddlProfissao"]);

                #endregion
            }
            else
            {
                #region PessoaJuridica

                titular.PessoaJuridica = new PessoaJuridicaEnt();
                titular.PessoaJuridica.Responsavel = new List<ResponsavelEnt>();
                titular.PessoaJuridica.Responsavel = responsavel;

                if (!String.IsNullOrEmpty(Request.Form["txtCnpj"]))
                    titular.PessoaJuridica.CNPJPJ = txtCnpj.Text;
                if (!String.IsNullOrEmpty(CNPJFranqueado))
                    titular.PessoaJuridica.CNPJ = CNPJFranqueado;
                if (!String.IsNullOrEmpty(Request.Form["txtRazaoSocial"]))
                    titular.PessoaJuridica.RazaoSocial = Request.Form["txtRazaoSocial"];

                if (!String.IsNullOrEmpty(Request.Form["txtNomeFantasia"]))
                    titular.PessoaJuridica.NomeFantasia = Request.Form["txtNomeFantasia"];
                if (!String.IsNullOrEmpty(Request.Form["txtInscMunicipal"]))
                    titular.PessoaJuridica.InscrMunicipal = Request.Form["txtInscMunicipal"];
                if (!String.IsNullOrEmpty(Request.Form["txtInscEstadual"]))
                    titular.PessoaJuridica.InscrEstadual = Request.Form["txtInscEstadual"];
                if (!String.IsNullOrEmpty(Request.Form["txtDataFundacao"]))
                    titular.PessoaJuridica.DataFundacao = DateTime.Parse(Request.Form["txtDataFundacao"]);

                if (!String.IsNullOrEmpty(Request.Form["txtRendaMensal"]))
                    titular.PessoaJuridica.PatrimonioLiquido = Convert.ToDecimal(Request.Form["txtRendaMensal"].Replace(".", ""));


                #endregion
            }

            #region Email

            if (email.Count > 0)
                titular.Email = email;

            #endregion

            #region Telefone

            if (telefone.Count > 0)
                titular.Telefone = telefone;

            #endregion

            #region Endereco

            if (endereco.Count > 0)
                titular.Endereco = endereco;

            #endregion

            retorno = CadastroService.AtualizarClienteDadosTitular(titular);

            if (retorno)
            {
                Session["Operacao"] = "Sucesso";
                Session["Mensagem"] = "Cliente atualizado com sucesso!";
                Session["NumeroCartao"] = "";

                string query = "";
                if (Session["ValorPesquisa"] != null && Session["TipoPesquisa"] != null)
                    query = "?ValorPesquisa=" + Session["ValorPesquisa"].ToString() + "&TipoPesquisa=" + Session["TipoPesquisa"];

                string href = "MenuTitular.aspx";
                if (Session["LinkVoltar"] != null)
                    href = Session["LinkVoltar"].ToString();

                Response.Redirect(href + query, false);
            }

        }
            
        if (!retorno)
        {
            Session["Operacao"] = "Erro";
            Response.Redirect("MenuTitular.aspx", false);
        }

    }


    #endregion

    #region WebMethods

    [WebMethod(EnableSession = true)]
    public static bool TitularExiste(string cpf_cnpj)
    {
        try
        {
            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            return CadastroService.TitularExiste(cpf_cnpj);

        }
        catch
        {
            throw;
        }
    }

    [WebMethod(EnableSession = true)]
    public static bool ContatoExiste(string email)
    {
        try
        {
            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            return CadastroService.EmailExiste(email);

        }
        catch
        {
            throw;
        }
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
    public static JsonResult ObterListaBandeira()
    {
        var ret = new JsonResult();

        try
        {
            var sessao = VerificarSessao();
            
            if (!sessao) {
                ret.Resposta = false;
                ret.Mensagem = "SessaoFinalizada";
                return ret;
            }

            CadastroService = new CadastroPessoaClient();
            CadastroService.SetCNPJFranquia(CNPJFranqueado);
            ret.Resultado = CadastroService.ObterListaBandeira();
            ret.Resposta = true;
            
        }
        catch(Exception ex)
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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterListaEstadoCivil()
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
            ret.Resultado = CadastroService.ObterListaEstadoCivil();
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
            if (!VerificarSessao())
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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterListaProfissao()
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
            ret.Resultado = CadastroService.ObterListaProfissao();
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
    public static JsonResult ObterListaTipoEndereco()
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
            ret.Resultado = CadastroService.ObterListaTipoEndereco();
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
    public static JsonResult ObterListaTipoEmpresa()
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
            ret.Resultado = CadastroService.ObterListaTipoEmpresa();
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
    public static JsonResult ObterListaTipoTelefone()
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
            ret.Resultado = CadastroService.ObterListaTipoTelefone();
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
    public static JsonResult ObterListaTipoResponsavel()
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
            ret.Resultado = CadastroService.ObterListaTipoResponsavel();
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

    //public static string GetRequest(this String str)
    //{
    //    str = Regex.Replace(str, @"[^\x20-\x7F]", "");
    //    return str;
    //}

    private TitularEnt ObterTitular(string codConta)
    {
        CadastroService = new CadastroPessoaClient();
        CadastroService.SetCNPJFranquia(CNPJFranqueado);

        var titular = CadastroService.ObterTitular(codConta, "CONTA").FirstOrDefault();

        return titular;

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
        //catch { }

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

    #endregion

}