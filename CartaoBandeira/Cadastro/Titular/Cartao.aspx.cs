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

public partial class Cartao : System.Web.UI.Page
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

        if (Request["via2"] != "" && Request["via2"] == "true")
            Session["OperacaoCartao"] = "Alteracao2Via";
        else
            Session["OperacaoCartao"] = "AlteracaoStatus";

        VerificarSessao();

        if (!Page.IsPostBack)
        {
            string query = "";
            if (Session["ValorPesquisa"] != null && Session["TipoPesquisa"] != null)
                query = "?ValorPesquisa=" + Session["ValorPesquisa"].ToString() + "&TipoPesquisa=" + Session["TipoPesquisa"];

            if (Session["LinkVoltar"] != null)
                Redirect = Session["LinkVoltar"].ToString();

            Redirect = Redirect + query;
                
            this.btnVoltar.Attributes["href"] = Redirect;

            var motivos = (List<ListaEnt>)ObterListaMotivo().Resultado;

            var codConta = Request["conta"];
            
            var titular = ObterTitular(codConta);
            
            if (titular.PessoaFisica != null)
            {
                this.lblCpfCnpj.Text = "CPF:";
                this.lbNome.Text = "Nome do Cliente Titular:";
                this.lblCpfCnpjTitular.Text = titular.PessoaFisica.CPF.Substring(0, 3) + '.' + titular.PessoaFisica.CPF.Substring(3, 3) + '.' + titular.PessoaFisica.CPF.Substring(6, 3) + "-" + titular.PessoaFisica.CPF.Substring(9, 2);
                this.lblNomeTitular.Text = titular.PessoaFisica.NomeCompleto;

                this.lblDataNascimento.Text = titular.PessoaFisica.DataNasc.Value.ToString("dd/MM/yyyy");
                this.lblNomeMae.Text = titular.PessoaFisica.NomeMae;

                string endereco = "";
                if (titular.Endereco != null && titular.Endereco.Count > 0)
                {
                    foreach (var item in titular.Endereco)
                    {
                        if (item.CodTipoEndereco == 1) // residencial
                        {
                            endereco = item.Logradouro + ", " + item.Numero + ' ' + item.Complemento + " - " + item.Bairro + "<br> CEP:" + item.CEP.Substring(0, 5) + "-" + item.CEP.Substring(5) + " - " + item.Municipio + "/" + item.UF;
                            break;
                        }
                    }
                    this.lblEndereco.Text = endereco;
                }

            }
            else
            {
                this.lblCpfCnpj.Text = "CNPJ:";
                this.lbNome.Text = "Nome do Cliente Empresa Titular:";
                this.lblCpfCnpjTitular.Text = titular.PessoaJuridica.CNPJPJ.Substring(0, 2) + "." + titular.PessoaJuridica.CNPJPJ.Substring(2, 3) + "." + titular.PessoaJuridica.CNPJPJ.Substring(5, 3) + "/" + titular.PessoaJuridica.CNPJPJ.Substring(8, 4) + "-" + titular.PessoaJuridica.CNPJPJ.Substring(12);
                this.lblNomeTitular.Text = titular.PessoaJuridica.NomeFantasia;

                this.divCadastroPF.Attributes["class"] += " display-none";

                string endereco = "";
                if (titular.Endereco != null && titular.Endereco.Count > 0)
                {
                    foreach (var item in titular.Endereco)
                    {
                        if (item.CodTipoEndereco == 2) // comercial
                        {
                            endereco = item.Logradouro + ", " + item.Numero + ' ' + item.Complemento + " - " + item.Bairro + "<br> CEP:" + item.CEP.Substring(0, 5) + "-" + item.CEP.Substring(5) + " - " + item.Municipio + "/" + item.UF;
                            break;
                        }
                    }
                    this.lblEndereco.Text = endereco;
                }
            }

            this.hdnTitular.Value = JsonConvert.SerializeObject(titular);
            this.hdnMotivo.Value = JsonConvert.SerializeObject(motivos);
            
        }

    }

    protected void btnConfirmar_Click(object sender, EventArgs e)
    {
        var retorno = false;
        var operacaoCartao = "";

        CadastroPessoaClient CadastroService = new CadastroPessoaClient();
        CadastroService.SetCNPJFranquia(CNPJFranqueado);
        CadastroService.SetLogin(UserName);

        var nomeCartao = GetRequest(Request.Form["txtNomeCartao"]);
        var codCartao = Convert.ToInt32(GetRequest(Request.Form["hdnCodCartao"])); 
        var novaSenha = !string.IsNullOrEmpty(GetRequest(Request.Form["hdnNovaSenha"]));

        if (novaSenha)
        {
            operacaoCartao = "NovaSenha";
            retorno = CadastroService.SolicitarNovaSenha(codCartao);
        }
        else
        {
            if (Session["OperacaoCartao"] != null)
            {
                if (Session["OperacaoCartao"].ToString() == "Alteracao2Via")
                {
                    var codMotivoStatusCartao = Convert.ToInt32(GetRequest(Request.Form["hdnCodMotivoStatusCartao"]));
                    operacaoCartao = "Alteracao2Via";

                    retorno = CadastroService.SolicitarSegundaVia(codCartao, codMotivoStatusCartao, nomeCartao);
                }
                else if (Session["OperacaoCartao"].ToString() == "AlteracaoStatus")
                {
                    operacaoCartao = "AlteracaoStatus";
                    var codMotivoStatusCartao = Convert.ToInt32(GetRequest(Request.Form["hdnCodMotivoStatusCartao"]));

                    retorno = CadastroService.AtualizarMotivoStatusCartao(codCartao, codMotivoStatusCartao);
                }
            }
        }

        if (retorno)
        {
            Session["Operacao"] = "Sucesso";
            if (operacaoCartao == "NovaSenha")
                Session["Mensagem"] = "Senha solicitada com sucesso!";
            else if (operacaoCartao == "Alteracao2Via")
                Session["Mensagem"] = "Segunda via solicitada com sucesso!";
            else if (operacaoCartao == "AlteracaoStatus")
                Session["Mensagem"] = "Cartão atualizado com sucesso!";

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

    [WebMethod(EnableSession = true)]
    public static JsonResult ObterListaMotivo()
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
            ret.Resultado = CadastroService.ObterListaMotivo();
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
    public static JsonResult ObterListaMotivoStatusCartao(int codStatusCartao)
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
            ret.Resultado = CadastroService.ObterListaMotivoStatusCartao(codStatusCartao);
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
    public static JsonResult VerificarSolicitarSegundaVia(int codCartao, int codMotivo)
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
            ret.Resultado = CadastroService.VerificarSolicitarSegundaVia(codCartao, codMotivo);
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
    public static JsonResult VerificarAtualizarMotivoStatusCartao(int codCartao, int codMotivoStatusCartao)
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
            ret.Resultado = CadastroService.VerificarAtualizarMotivoStatusCartao(codCartao, codMotivoStatusCartao);
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

    private TitularEnt ObterTitular(string codConta)
    {
        CadastroService = new CadastroPessoaClient();
        CadastroService.SetCNPJFranquia(CNPJFranqueado);

        var titular = CadastroService.ObterTitular(codConta, "CONTA").FirstOrDefault();

        // por questão de segurança limpamos os dados desnecessários
        titular.DadosBancario = null;
        titular.Email = null;
        titular.Telefone = null;
        //titular.Endereco = null;

        ////////////////////////////////////////////
        // Marcelo - Não mais filtramos os cancelado
        ////////////////////////////////////////////

        /*
        // filtramos somentes os cartões que não estejam cancelados
        titular.Conta.ContaProduto = titular.Conta.ContaProduto.Where(s => s.Cartao.CodStatusCartao != 3).ToList();

        foreach (var item in titular.Conta.ContaProduto)
        {
            if (item.Cartao.Adicional != null && item.Cartao.Adicional.Count > 0)
            {
                // filtramos somentes os cartões que não estejam cancelados
                item.Cartao.Adicional = item.Cartao.Adicional.Where(s => s.CartaoAdicional.CodStatusCartao != 3).ToList();
            }
        }

        */

        return titular;

    }

    private bool ValidarFiltro()
    {
        //Validacao valida = new Validacao();

        return true;

    }

    public string GetRequest(string str)
    {
        if (!string.IsNullOrEmpty(str))
            str = Regex.Replace(str, @"[^\x20-\x7F]", "");
        return str;
    }

    #endregion

}

