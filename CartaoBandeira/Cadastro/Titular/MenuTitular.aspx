<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MenuTitular.aspx.cs" Inherits="MenuTitular" %>
<!DOCTYPE html>
<html>
<head id="Head1" runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=edge; IE=11; IE=10; IE=9; IE=8; IE=7" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Portal Card</title>
    
    <link rel="stylesheet" type="text/css" href="../../css/bootstrap.min.css" />
    <link rel="stylesheet" type="text/css" href="../../css/bootstrap-theme.min.css" />
    <link rel="stylesheet" type="text/css" href="../../css/sb-admin-2.min.css" />
    <link rel="stylesheet" type="text/css" href="../../css/jquery-ui.min.css" />
    <link rel="stylesheet" type="text/css" href="../../css/metisMenu/metisMenu.min.css" />
    <link rel="stylesheet" type="text/css" href="../../css/font-awesome/css/font-awesome.min.css" />
    <link rel="stylesheet" type="text/css" href="../../css/default.css" />

    <link rel="stylesheet" type="text/css" href="../../css/cssTitular.css" />

    <script language="javascript" type="text/javascript" src="../../js/jquery-3.1.1.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.mask.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.maskMoney.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/bootstrap.js"></script>
    <%--<script language="javascript" type="text/javascript" src="../../js/bootstrap-checkbox.min.js"></script>--%>
    <script language="javascript" type="text/javascript" src="../../js/metisMenu/metisMenu.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/sb-admin-2.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/default.js"></script>
    <script language="javascript" type="text/javascript">

        $(document).ready(function () {
            CarregaForm();
        });

        function CarregaForm() {

            $('#chkCartaoAtivo').on('change', function () {
                consultaTitular();
            });

            $(".input-numeric, .input-date, .input-cpf, .input-cnpj, .input-cep, .input-phone, .input-money, .input-creditcard").keydown(function (event) {
                if (!isNumeric($(this).val()))
                    $(this).val('');

            });

            $('#txtPesquisa').off("keypress").on('keypress', function (e) {
                if (e.which == 13) {
                    if ($("[name=optBusca]:checked").val() == "NOME") {
                        $(this).val(formataNome($(this).val()));
                    }
                    consultaTitular();
                    return false;
                }

                return e.which !== 13;

            });

            $("#txtPesquisa").keypress(function (event) {

                if (event.ctrlKey)
                    return true;

                var busca = $("[name=optBusca]:checked").val();
                if (busca != 'NOME') {
                    return isKeyNumeric(event);
                }

            });

            $("#txtPesquisa").keydown(function (event) {
                var busca = $("[name=optBusca]:checked").val();
                if (busca != 'NOME') {
                    if (!isNumeric($(this).val()))
                        $(this).val('');
                }

            });

            $("#btnBuscar").off("click").on("click", function () {
                consultaTitular();
            });

            // configuramos a máscara para o controle de pesquisa
            var busca = $("[name=optBusca]:checked").val()
            if (busca == 'CPF') {
                $('#txtPesquisa').mask('999.999.999-99', { placeholder: 'CPF do titular' });
            }
            else if (busca == 'CNPJ') {
                $('#txtPesquisa').mask('99.999.999/9999-99', { placeholder: 'CNPJ do titular' });
            }
            else if (busca == 'CARTAO') {
                $('#txtPesquisa').mask('9999 9999 9999 9999', { placeholder: 'Cartão do titular' });
            }
            else if (busca == 'PROPOSTA') {
                $('#txtPesquisa').mask('999999999999999999', { placeholder: 'Número da proposta' });
            }
            else if (busca == 'NOME') {
                $('#txtPesquisa').attr('placeholder', 'Nome do titular');
                $("#txtPesquisa").unmask();
            }

            $("#txtPesquisa").focusout(function () {
                if ($("#txtPesquisa").val() == "") return;

                var busca = $("[name=optBusca]:checked").val()
                if (busca == 'CPF') {
                    if (!validaCpf($(this).val().trim())) {
                        exibePopover($(this), "CPF inválido");

                        if ($(this).attr('data-required') !== undefined) {
                            if ($(this).attr('data-required') == "" || $(this).attr('data-required').toLowerCase() != "false") {
                                exibeError($(this), true);
                            }
                        }
                    }
                }
                else if (busca == 'CNPJ') {
                    if (!validaCnpj($(this).val().trim())) {
                        exibePopover($(this), "CNPJ inválido");

                        if ($(this).attr('data-required') !== undefined) {
                            if ($(this).attr('data-required') == "" || $(this).attr('data-required').toLowerCase() != "false") {
                                exibeError($(this), true);
                            }
                        }
                    }
                }
                else if (busca == 'CARTAO') {
                    if ($(this).val().trim().length != 19) {
                        exibePopover($(this), "Cartão inválido");

                        if ($(this).attr('data-required') !== undefined) {
                            if ($(this).attr('data-required') == "" || $(this).attr('data-required').toLowerCase() != "false") {
                                exibeError($(this), true);
                            }
                        }
                    }
                }
                else if (busca == 'NOME') {
                    $(this).val(formataNome($(this).val()));
                }

            });

            // método para carregar o tipo de pesquisa
            $('input[type=radio][name=optBusca]').change(function () {
                if (this.value == 'CPF') {
                    $('#txtPesquisa').mask('999.999.999-99', { placeholder: 'CPF do titular' });
                }
                else if (this.value == 'CNPJ') {
                    $('#txtPesquisa').mask('99.999.999/9999-99', { placeholder: 'CNPJ do titular' });
                }
                else if (this.value == 'CARTAO') {
                    $('#txtPesquisa').mask('9999 9999 9999 9999', { placeholder: 'Cartão do titular' });
                }
                else if (this.value == 'PROPOSTA') {
                    $('#txtPesquisa').mask('999999999999999999', { placeholder: 'Número da proposta' });
                }
                else if (this.value == 'NOME') {
                    //$('#txtPesquisa').mask('', { placeholder: 'Nome do titular' });
                    $('#txtPesquisa').attr('placeholder', 'Nome do titular');
                    $("#txtPesquisa").unmask();
                }

                $('#txtPesquisa').val('');
                exibeError($('#txtPesquisa'), false);
                $('#txtPesquisa').focus();

            });

            //$('[id*=btnAlterar]').click(function () {
            //    $(".loading").fadeIn("slow");
            //});

            //$('[id*=btnConsultar]').click(function () {
            //    $(".loading").fadeIn("slow");
            //});

            //////////////////////////////////////
            //var tipoPesquisa = $('[id$=hdnTipoPesquisa]').val();
            //var valorPesquisa = $('[id$=hdnValorPesquisa]').val();
            var tipoPesquisa = request('TipoPesquisa');
            var valorPesquisa = request('ValorPesquisa');

            if (!isNullOrEmpty(valorPesquisa) && !isNullOrEmpty(tipoPesquisa)) {

                if (tipoPesquisa == "CPF") {
                    $("input[name=optBusca][id=optCPF]").prop('checked', true);
                    $('#txtPesquisa').mask('999.999.999-99', { placeholder: 'CPF do titular' });
                }
                else if (tipoPesquisa == "CNPJ") {
                    $("input[name=optBusca][id=optCNPJ]").prop('checked', true);
                    $('#txtPesquisa').mask('99.999.999/9999-99', { placeholder: 'CNPJ do titular' });
                }
                else if (tipoPesquisa == "CARTAO") {
                    $("input[name=optBusca][id=optCartao]").prop('checked', true);
                    $('#txtPesquisa').mask('9999 9999 9999 9999', { placeholder: 'Cartão do titular' });
                }
                else if (tipoPesquisa == "PROPOSTA") {
                    $("input[name=optBusca][id=optProposta]").prop('checked', true);
                    $('#txtPesquisa').attr('placeholder', 'Número da proposta');
                    $("#txtPesquisa").unmask();
                }
                else if (tipoPesquisa == "NOME") {
                    $("input[name=optBusca][id=optNome]").prop('checked', true);
                    //$('#txtPesquisa').mask('', { placeholder: 'Nome do titular' });
                    $('#txtPesquisa').attr('placeholder', 'Nome do titular');
                    $("#txtPesquisa").unmask();
                }

                $("#txtPesquisa").val(valorPesquisa);

                //$('[id$=hdnTipoPesquisa]').val('');
                //$('[id$=hdnValorPesquisa]').val('');

                consultaTitular();

            }
            else {
                $("input[name=optBusca][id=optCPF]").prop('checked', true);
                $('#txtPesquisa').mask('999.999.999-99', { placeholder: 'CPF do titular' });
            }

            //////////////////////////////////////

            $('#btnIncluirClientePessoaFisica').click(function () {
                $('#btnIncluirClientePessoaFisica').blur()
                $(".loading").fadeIn("slow");
                window.location.href = "Titular.aspx?usuario=pf";
            });

            $('#btnIncluirClientePessoaJuridica').click(function () {
                $('#btnIncluirClientePessoaJuridica').blur()
                $(".loading").fadeIn("slow");
                window.location.href = "Titular.aspx?usuario=pj";
            });

            $('#txtPesquisa').focus();
            $(".loading").fadeOut("slow");

        }

        function consultaTitular() {

            try {

                if (ValidaPesquisa()) {

                    $(".loading").fadeIn("slow");
                    $("#divListaResultado").slideUp();

                    /// exemplo: passando o form inteiro para o webmethod
                    //var form = $("form").serializeArray();
                    //var param = JSON.stringify({ dataForm: form });

                    /// exemplo: passando parametros especificos para o webmethod
                    //var form = new Object();
                    //form.Pesquisa = $('#txtPesquisa').val();
                    //form.TipoPesquisa = $("[name=optBusca]:checked").val();
                    //var param = JSON.stringify(form);

                    //var param = JSON.stringify({
                    //    valorPesquisa: '123',
                    //    tipoPesquisa: 'CPF'
                    //});
                    //CallAjaxJson('Titular.aspx/ObterListaBandeira', param, true, funcaoSucesso, funcaoErro);
                    //function funcaoSucesso(ret) {
                    //    carregaTitular(jsonResult.Resultado);    
                    //}
                    //function funcaoErro(ret) {
                    //    window.location.href = "../../Erro.aspx";
                    //}

                    var param = JSON.stringify({
                        valorPesquisa: $('#txtPesquisa').val(),
                        tipoPesquisa: $("[name=optBusca]:checked").val()
                    });

                    setTimeout(function () {

                        $.ajax({
                            type: "POST",
                            contentType: "application/json; charset=utf-8",
                            url: 'MenuTitular.aspx/ConsultaTitular',
                            data: param,
                            dataType: "json",
                            async: false,
                            success: function (response) {

                                var jsonResult = response.d;

                                if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {
                                    $("#table-resultado tbody tr").remove();

                                    $(".loading").fadeOut("slow");

                                    carregaTitular(jsonResult.Resultado);
                                    $("#divListaResultado").slideDown();
                                }
                                else if (!jsonResult.Resposta && jsonResult.Mensagem == "SessaoFinalizada") {
                                    window.location.href = "../../SessaoFinalizada.aspx";
                                }
                                else if (!jsonResult.Resposta && jsonResult.Mensagem == "ValidaDados") {
                                    $(".loading").fadeOut("slow");
                                    $('#modalError').modal('show');
                                }
                                else if (jsonResult.Erro) {
                                    console.log(jsonResult.Mensagem);
                                    window.location.href = "../../Erro.aspx";
                                }
                                else {
                                    $(".loading").fadeOut("slow");
                                    setTimeout(function () {
                                        exibeCampoObrigatorio($('#txtPesquisa'), "Cliente não encontrado!");
                                    }, 500);
                                }

                            },
                            error: function (response) {
                                $("#table-resultado tbody tr").remove();

                                $(".loading").fadeOut("slow");
                                //$('#modalError').modal('show');
                                window.location.href = "../../Erro.aspx";

                            }
                        })

                    }, 500);

                }

                $(".loading").fadeOut("slow");

            }
            catch (Erro) {
                $(".loading").fadeOut("slow");
                $("#MensagemErro").text('Erro ao validar os dados do cliente!');
                $("#modalErro").modal("show");
                return false;
            }
        }

        function carregaTitular(titular) {

            if (titular != null) {
                var html = "";

                for (i in titular) {

                    var nome = "";
                    var cpf_cnpj = "";

                    if (titular[i].PessoaFisica != null) {
                        nome = titular[i].PessoaFisica.NomeCompleto;
                        cpf_cnpj = titular[i].PessoaFisica.CPF;
                        cpf_cnpj = cpf_cnpj.substring(0, 3) + "." + cpf_cnpj.substring(3, 6) + "." + cpf_cnpj.substring(6, 9) + "-" + cpf_cnpj.substring(9)
                    }
                    else {
                        nome = titular[i].PessoaJuridica.NomeFantasia;
                        cpf_cnpj = titular[i].PessoaJuridica.CNPJPJ;
                        cpf_cnpj = cpf_cnpj.substring(0, 2) + "." + cpf_cnpj.substring(2, 5) + "." + cpf_cnpj.substring(5, 8) + "/" + cpf_cnpj.substring(8, 12) + "-" + cpf_cnpj.substring(12)
                    }

                    html = "<tr>";
                    html += "   <td style='vertical-align:middle'>" + cpf_cnpj + "</td>";
                    html += "   <td style='vertical-align:middle'>" + nome + "</td>";

                    var bandeira = "";
                    var produto = "";
                    var cartao = "";
                    var status = "";

                    for (j in titular[i].Conta.ContaProduto) {
                        var icon = "";
                        if (titular[i].Conta.ContaProduto[j].Cartao.CodStatusCartao == 1)
                            icon = "<span class='warning glyphicon glyphicon-ok color-green' data-toggle='tooltip' data-placement='top' title='" + titular[i].Conta.ContaProduto[j].Cartao.StatusCartao + "'></span>";
                        else if (titular[i].Conta.ContaProduto[j].Cartao.CodStatusCartao == 2)
                            icon = "<span class='warning glyphicon glyphicon-lock color-yellow' data-toggle='tooltip' data-placement='top' title='" + titular[i].Conta.ContaProduto[j].Cartao.StatusCartao + " - Motivo: " + titular[i].Conta.ContaProduto[j].Cartao.MotivoCartao + "'></span>";
                        else if (titular[i].Conta.ContaProduto[j].Cartao.CodStatusCartao == 3)
                            icon = "<span class='glyphicon glyphicon-remove color-red' data-toggle='tooltip' data-placement='top' title='" + titular[i].Conta.ContaProduto[j].Cartao.StatusCartao + " - Motivo: " + titular[i].Conta.ContaProduto[j].Cartao.MotivoCartao + "'></span>";

                        cartao += titular[i].Conta.ContaProduto[j].Cartao.NumeroCartao + "<br>"
                        bandeira += titular[i].Conta.ContaProduto[j].Cartao.NomeBandeira + "<br>"
                        produto += titular[i].Conta.ContaProduto[j].Cartao.NomeProduto + "<br>"
                        status += icon + "<br>"
                    }
                    

                    html += "   <td style='vertical-align:middle'>" + cartao + "</td>";
                    html += "   <td style='vertical-align:middle; text-align:center'>" + bandeira + "</td>";
                    html += "   <td style='vertical-align:middle; text-align:center'>" + produto + "</td>";
                    html += "   <td style='vertical-align:middle; text-align:center'>" + status + "</td>";

                    var menuCartao = "";
                    menuCartao += "<div data-toggle='tooltip' title='cartão' style='display:inline-block'>";
                    menuCartao += "<div id='menuCartao' class='dropdown'>";
                    menuCartao += "    <span class='btn btn-outline btn-primary btn-xs glyphicon glyphicon-credit-card dropdown-toggle' data-submenu data-toggle='dropdown' data-placement='top' ></span>";
                    menuCartao += "    <ul class='dropdown-menu action'>";
                    menuCartao += "        <li><a href='Produto.aspx?conta=" + titular[i].CodConta + "'><i class='glyphicon glyphicon-credit-card'></i> Incluir Cartão</a></li>";
                    menuCartao += "        <li><a href='Cartao.aspx?conta=" + titular[i].CodConta + "'><i class='glyphicon glyphicon-cog'></i> Alterar Status do Cartão</a></li>";
                    menuCartao += "        <li><a href='Limite.aspx?conta=" + titular[i].CodConta + "'><i class='glyphicon glyphicon-usd'></i> Alterar Limites do Cartão</a></li>";
                    menuCartao += "        <li><a href='Cartao.aspx?conta=" + titular[i].CodConta + "&via2=true'><i class='glyphicon glyphicon-duplicate'></i> Solicitar 2ª via do Cartão</a></li>";
                    menuCartao += "        <li><a href='../Adicional/Adicional.aspx?operacao=incluir&titular=" + cpf_cnpj + "&conta=" + titular[i].CodConta + "'><i class='glyphicon glyphicon-plus-sign'></i> Incluir Cartão Adicional</a></li>";
                    menuCartao += "    </ul>";
                    menuCartao += "</div>";
                    menuCartao += "</div>";

                    //html += "   <td style='vertical-align:middle; text-align:center'><a href='Titular.aspx?conta=" + titular[i].CodConta + "' class='action btn btn-outline btn-primary btn-xs glyphicon glyphicon-edit' data-toggle='tooltip' data-placement='top' title='alterar dados cadastrais' /> <a href='Limite.aspx?conta=" + titular[i].CodConta + "' class='action btn btn-outline btn-primary btn-xs glyphicon glyphicon-usd' data-toggle='tooltip' data-placement='top' title='alterar limites do cartão' /> <a href='Produto.aspx?conta=" + titular[i].CodConta + "' class='action btn btn-outline btn-primary btn-xs glyphicon glyphicon-credit-card' data-toggle='tooltip' data-placement='top' title='incluir novo cartão' /> <a href='Cartao.aspx?conta=" + titular[i].CodConta + "' class='action btn btn-outline btn-primary btn-xs glyphicon glyphicon-duplicate' data-toggle='tooltip' data-placement='top' title='solicitar 2ª via do cartão' /> <a href='../Adicional/Adicional.aspx?operacao=incluir&titular=" + cpf_cnpj + "&conta=" + titular[i].CodConta + "' class='action btn btn-outline btn-primary btn-xs glyphicon glyphicon-plus-sign' data-toggle='tooltip' data-placement='top' title='incluir cartão adicional' /> </td>";
                    html += "   <td style='vertical-align:middle; text-align:center'><a href='Titular.aspx?conta=" + titular[i].CodConta + "' class='action btn btn-outline btn-primary btn-xs glyphicon glyphicon-edit' data-toggle='tooltip' data-placement='top' title='dados cadastrais' /> " + menuCartao + " </td>";

                    html += "</tr>";

                    var table = $("#table-resultado tbody");
                    table.append(html);

                    $(".action").click(function (event) {
                        $(".loading").fadeIn("slow");
                        //setTimeout(function () {
                        //    $(".loading").fadeOut("slow");
                        //}, 200);

                        $(this).blur();
                    });
                }
            }
        }

        function ValidaPesquisa() {

            if ($('#txtPesquisa').val() == "") {
                exibeError($('#txtPesquisa'), true);
                $('#txtPesquisa').focus();
                return false;
            }

            var busca = $("[name=optBusca]:checked").val()
            if (busca == 'CPF') {

                if (!validaCpf($('#txtPesquisa').val().trim())) {
                    setTimeout(function () {
                        exibeCampoObrigatorio($('#txtPesquisa'), "CPF inválido!");
                        $('#txtPesquisa').focus();
                    }, 200);
                    return false;
                }
            }
            else if (busca == 'CNPJ') {
                if (!validaCnpj($('#txtPesquisa').val().trim())) {
                    setTimeout(function () {
                        exibeCampoObrigatorio($('#txtPesquisa'), "CNPJ inválido!");
                        $('#txtPesquisa').focus();
                    }, 200);
                    return false;
                }
            }
            else if (busca == 'CARTAO') {
                if ($('#txtPesquisa').val().trim().length != 19) {
                    setTimeout(function () {
                        exibeCampoObrigatorio($('#txtPesquisa'), "Cartão inválido!");
                        $('#txtPesquisa').focus();
                    }, 200);
                    return false;
                }
            }
            else if (busca == 'NOME') {
                if ($('#txtPesquisa').val().trim().length < 3) {
                    setTimeout(function () {
                        exibeCampoObrigatorio($('#txtPesquisa'), "Informe o mínimo 3 caracteres!");
                        $('#txtPesquisa').focus();
                    }, 200);
                    return false;
                }
            }

            $(".loading").fadeIn("slow");
            return true;
        }

    </script>
</head>
<body class="fadeIn">
    <form id="form1" autocomplete="off" runat="server">
    <asp:ScriptManager runat="server">
    </asp:ScriptManager>
    <asp:HiddenField ID="hdnOperacao" runat="server" Value="" />
    <asp:HiddenField ID="hdnNumeroCartao" runat="server" Value="" />
    <asp:HiddenField ID="hdnMensagem" runat="server" Value="" />
    <div class="container">
        <div class="content">
            <div class="row">
                <div class="col-md-12">
                    <h3 class="page-header">
                        Cliente Titular</h3>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel-body">
                        <div class="row">
                            <div class="panel panel-default">
                                <div class="panel-heading panel-font">
                                    Consulta Clientes
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label class="radio-inline">
                                            <input runat="server" type="radio" name="optBusca" id="optCPF" value="CPF" />CPF
                                        </label>
                                        <label class="radio-inline">
                                            <input type="radio" name="optBusca" id="optCNPJ" value="CNPJ" />CNPJ
                                        </label>
                                        <%--<label class="radio-inline">
                                            <input runat="server" type="radio" name="optBusca" id="optCartao" value="CARTAO" />Cartão
                                        </label>--%>
                                        <label class="radio-inline">
                                            <input runat="server" type="radio" name="optBusca" id="optNome" value="NOME" />Nome
                                        </label>
                                        <%--<label class="radio-inline">
                                            <input runat="server" type="radio" name="optBusca" id="optProposta" value="PROPOSTA" />Proposta
                                        </label>--%>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <asp:TextBox ID="txtPesquisa" runat="server" Text="" MaxLength="50" data-required="true"
                                                    CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <button type="button" id="btnBuscar" usesubmitbehavior="False" class="btn btn-default">
                                                    <i class="fa fa-search"></i> Buscar</button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row display-none">
                                        <div class="col-md-6">
                                            <div class="dropdown">
                                                <span class='btn btn-outline btn-primary btn-xs glyphicon glyphicon-credit-card dropdown-toggle'
                                                    data-submenu data-toggle='dropdown' data-placement='top' title='alterar dados cadastrais'>
                                                </span>
                                                <ul class="dropdown-menu">
                                                    <li><a href="#"><i class="glyphicon glyphicon-credit-card"></i>Incluir Cartão</a></li>
                                                    <li><a href="#"><i class="glyphicon glyphicon-cog"></i>Alterar Situação do Cartão</a></li>
                                                    <li><a href="#"><i class="glyphicon glyphicon-usd"></i>Alterar Limites do Cartão</a></li>
                                                    <li><a href="#"><i class="glyphicon glyphicon-duplicate"></i>Solicitar 2ª do Cartão</a></li>
                                                    <li><a href="#"><i class="glyphicon glyphicon-plus-sign"></i>Incluir Cartão Adicional</a></li>
                                                </ul>
                                            </div>
                                            <%--<input id="chkCartaoAtivo" type="checkbox" data-off-title="cartões cancelados" data-on-title="cartões não cancelados" data-reverse checked />--%>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <%--<div id="divMensagemErro" class="alert alert-danger display-none">
                                    Pessoa Física não encontrada!
                                </div>--%>
                                            <div id="divListaResultado" class="row display-none">
                                                <div class="col-md-12 bs-glyphicons">
                                                    <hr />
                                                    <table id="table-resultado" class="table table-hover table-responsive">
                                                        <thead>
                                                            <tr>
                                                                <th style="width: 130px">
                                                                    CPF/CNPJ
                                                                </th>
                                                                <th style="width: 200px">
                                                                    Nome
                                                                </th>
                                                                <th style="width: 150px">
                                                                    Cartão
                                                                </th>
                                                                <th style="width: 80px; text-align: center">
                                                                    Bandeira
                                                                </th>
                                                                <th style="width: 80px; text-align: center">
                                                                    Produto
                                                                </th>
                                                                <th style="width: 5px; text-align: center">
                                                                    Status
                                                                </th>
                                                                <th style="width: 150px; text-align: center">
                                                                    Ações
                                                                </th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row align-center">
                            <button type="button" id="btnIncluirClientePessoaFisica" runat="server" class="btn btn-outline btn-default"
                                style="width: 250px">
                                <i class="fa fa-user"></i>&nbsp;&nbsp; Incluir Cliente Pessoa Física</button>
                            <button type="button" id="btnIncluirClientePessoaJuridica" runat="server" class="btn btn-outline btn-default"
                                style="width: 250px">
                                <i class="fa fa-institution"></i>&nbsp;&nbsp; Incluir Cliente Pessoa Jurídica</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- mensagem -->
    <div class="modal fade alert" id="modalMensagem" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog alert-info" style="width: 450px">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title" id="myModalLabel">
                        Cliente Titular</h4>
                </div>
                <div class="modal-body align-center" style="font-size: 18px !important;" id="MensagemSucesso">
                    Cliente incluído com sucesso!
                    <br />
                </div>
                <div class="modal-body align-center display-none" id="divMensagemNumeroCartao">
                    <h4>
                        <span class="text-warning" style="color: #8a6d3b !important; font-size: 18px !important;"
                            id="MensagemNumeroCartao"></span>
                    </h4>
                </div>
                <div class="modal-footer">
                    <button id="btnOk" type="button" class="btn btn-primary center-block" data-dismiss="modal">
                        OK</button>
                </div>
            </div>
        </div>
    </div>
    <div class="modal fade alert" id="modalErro" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog alert-danger" style="width: 450px">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        Cliente Titular</h4>
                </div>
                <div class="modal-body align-center" style="font-size: 18px !important;" id="MensagemErro">
                    Erro ao realizar operação!
                </div>
                <div class="modal-footer">
                    <button id="Button1" type="button" class="btn btn-danger center-block" data-dismiss="modal">
                        OK</button>
                </div>
            </div>
        </div>
    </div>
    <div class="loading"></div>
    </form>
</body>
<script language="javascript" type="text/javascript">
    var operacao = $('[id$=hdnOperacao]').val();
    var mensagem = $('[id$=hdnMensagem]').val();
    var cartao = $('[id$=hdnNumeroCartao]').val();

    if (operacao == "Sucesso") {
        var modal = $("#modalMensagem");
        var modalMensagem = $("#MensagemSucesso");
        var modalMensagemNumeroCartao = $("#MensagemNumeroCartao");
        var divMensagemNumeroCartao = $("#divMensagemNumeroCartao");
        
        if ($('#modalMensagem', window.parent.document).length == 1) {
            modal = $('#modalMensagem', window.parent.document);
            modalMensagem = $('#MensagemSucesso', window.parent.document);
            modalMensagemNumeroCartao = $('#MensagemNumeroCartao', window.parent.document);
        }

        modalMensagem.text(mensagem);

        if (cartao != "") {
            modalMensagemNumeroCartao.text('Número do Cartão: ' + cartao);
            divMensagemNumeroCartao.show();
        }

        modal.modal("show");

    }
    else if (operacao == "Erro") {
        if ($('#modalErro', window.parent.document).length == 1) {
            $('#modalErro', window.parent.document).modal("show");
        }
        else {
            $("#modalErro").modal("show");
        }
    }

    $('[id$=hdnOperacao]').val('');
    $('[id$=hdnMensagem]').val('');
    $('[id$=hdnNumeroCartao]').val('');

    //$(':checkbox').checkboxpicker();

    //$('#chkCartaoAtivo').checkboxpicker({
    //    html: true,
    //    onLabel: '<span class="glyphicon glyphicon-ok">',
    //    offLabel: '<span class="glyphicon glyphicon-remove">'
    //});

</script>
</html>
