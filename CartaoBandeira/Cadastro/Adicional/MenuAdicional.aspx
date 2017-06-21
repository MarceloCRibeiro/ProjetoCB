<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MenuAdicional.aspx.cs" Inherits="MenuAdicional" %>
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

    <link rel="stylesheet" type="text/css" href="../../css/cssAdicional.css" />

    <%--<script language="javascript" type="text/javascript" src="../../js/jquery-1.9.1.js"></script>--%>
    <script language="javascript" type="text/javascript" src="../../js/jquery-3.1.1.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.mask.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.maskMoney.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/bootstrap.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/metisMenu/metisMenu.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/sb-admin-2.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/default.js"></script>
    <script language="javascript" type="text/javascript">

        var Titular = "";

        $(document).ready(function () {
            CarregaForm();

        });

        function CarregaForm() {

            $('#btnIncluirAdicional').prop("disabled", "disabled");

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

                $("#txtPesquisa").val(valorPesquisa);

                //$('[id$=hdnTipoPesquisa]').val('');
                //$('[id$=hdnValorPesquisa]').val('');

                consultaTitular();

            }
            else {
                $("input[name=optBusca][id=optCPF]").prop('checked', true);
                $('#txtPesquisa').mask('999.999.999-99', { placeholder: 'CPF do titular' });
                //$("input[name=optBusca][id=optCNPJ]").prop('checked', true);
                //$('#txtPesquisa').mask('99.999.999/9999-99', { placeholder: 'CNPJ do titular' });
                //$('#txtPesquisa').val('78.655.326/0001-44');
            }

            // método para carregar o tipo de pesquisa
            $('input[type=radio][name=optBusca]').change(function () {
                if (this.value == 'CPF') {
                    $('#txtPesquisa').mask('999.999.999-99', { placeholder: 'CPF do titular' });
                }
                else if (this.value == 'CNPJ') {
                    $('#txtPesquisa').mask('99.999.999/9999-99', { placeholder: 'CNPJ do titular' });
                }

                $('#txtPesquisa').val('');
                exibeError($('#txtPesquisa'), false);
                $('#txtPesquisa').focus();

            });

            $('#txtPesquisa').focusout(function (e) {
                if ($(this).val() == '') return;

                var busca = $("[name=optBusca]:checked").val()
                if (busca == 'CPF') {
                    if (!validaCpf($(this).val().trim())) {
                        $('#lblErro').text('');
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
                        $('#lblErro').text('');
                        exibePopover($(this), "CNPJ inválido");

                        if ($(this).attr('data-required') !== undefined) {
                            if ($(this).attr('data-required') == "" || $(this).attr('data-required').toLowerCase() != "false") {
                                exibeError($(this), true);
                            }
                        }
                    }
                }

            });

            $('#txtPesquisa').off("keypress").on('keypress', function (e) {
                if (e.which == 13)
                    consultaTitular();

                return e.which !== 13;

            });

            $("#txtPesquisa").keypress(function (event) {

                if (event.ctrlKey)
                    return true;

                return isKeyNumeric(event);
            });

            $("#txtPesquisa").keydown(function (event) {

                if (!isNumeric($(this).val()))
                    $(this).val('');

            });

            $("#btnBuscar").off("click").on("click", function () {
                consultaTitular();
            });


            $('#btnIncluirAdicional').click(function () {
                $(".loading").fadeIn("slow");
                window.location.href = "Adicional.aspx?operacao=incluir&titular=" + Titular;
            });

            $('#txtPesquisa').focus();

            $(".loading").fadeOut("slow");

        }

        function consultaTitular() {

            try {

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

                $("#divCartoesAdicionais").slideUp();
                $(".loading").fadeIn("slow");

                //Titular = $('#txtPesquisa').val().trim().replace(".", "").replace(".", "").replace("/", "").replace("-", "");
                Titular = $('#txtPesquisa').val().trim();

                var param = JSON.stringify({
                    valorPesquisa: Titular,
                    tipoPesquisa: $("[name=optBusca]:checked").val()
                });

                $("#divTitular").slideUp();
                $("#lblTitular").text('');
                $("#lblNomeTitular").text('');

                $("#divListaResultado").slideUp();
                $('#btnIncluirAdicional').prop("disabled", "disabled");

                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: 'MenuAdicional.aspx/ConsultaTitular',
                    data: param,
                    dataType: "json",
                    async: false,
                    success: function (response) {

                        var jsonResult = response.d;

                        if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                            $("#divTitular").slideDown();
                            if (jsonResult.Resultado[0].PessoaFisica != null) {
                                $("#lblTitular").text('Nome do Cliente Titular:');
                                $("#lblNomeTitular").text(jsonResult.Resultado[0].PessoaFisica.NomeCompleto);
                            }
                            else if (jsonResult.Resultado[0].PessoaJuridica != null) {
                                $("#lblTitular").text('Nome do Cliente Empresa Titular:');
                                $("#lblNomeTitular").text(jsonResult.Resultado[0].PessoaJuridica.NomeFantasia);
                            }

                            $("#table-resultado tbody tr").remove();
                            $("#divListaResultado").slideUp();

                            carregaAdicionais(jsonResult.Resultado);

                            $(".loading").fadeOut("slow");
                            $('#btnIncluirAdicional').prop("disabled", false);

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

                return true;

            }
            catch (Erro) {
                $(".loading").fadeOut("slow");
                $("#MensagemErro").text('Erro ao validar os dados do cliente!');
                $("#modalErro").modal("show");
                return false;
            }

        }

        function carregaAdicionais(titular) {
            var existeAdicional = false;

            if (titular != null) {
                var html = "";

                var produtos = titular[0].Conta.ContaProduto

                for (i in produtos) {
                    var cartaoTitular = produtos[i].Cartao;

                    if (cartaoTitular.Adicional != null && cartaoTitular.Adicional.length > 0) {
                        existeAdicional = true;
                        var adicionais = cartaoTitular.Adicional;
                        for (j in adicionais) {

                            var titular = adicionais[j].CartaoTitular.NumeroCartao;
                            var bandeira = adicionais[j].CartaoTitular.NomeBandeira;
                            var produto = adicionais[j].CartaoTitular.NomeProduto;
                            var adicional = adicionais[j].CartaoAdicional.NumeroCartao;
                            var codigo = adicionais[j].CartaoAdicional.CodAdicional;
                            var nome = adicionais[j].Nome;

                            html = "<tr>";
                            html += "   <td style='vertical-align:middle; text-align: center'>" + titular + "</td>";
                            html += "   <td style='vertical-align:middle; text-align: center'>" + bandeira + "</td>";
                            html += "   <td style='vertical-align:middle; text-align: center'>" + produto + "</td>";
                            html += "   <td style='vertical-align:middle; text-align: center'>" + adicional + "</td>";
                            html += "   <td style='vertical-align:middle;'>" + nome + "</td>";
                            html += "   <td style='vertical-align:middle; text-align:center'><a href='Adicional.aspx?operacao=alterar&titular=" + Titular + "&adicional=" + codigo + "' class='btn btn-outline btn-primary btn-xs glyphicon glyphicon-edit' data-toggle='tooltip' data-placement='top' title='editar cartão adicional' /> <a href='Adicional.aspx?operacao=consultar&titular=" + Titular + "&adicional=" + codigo + "' class='btn btn-outline btn-primary btn-xs glyphicon glyphicon-search' data-toggle='tooltip' data-placement='top' title='consultar cartão adicional' /></td>";
                            html += "</tr>";

                            var table = $("#table-resultado tbody");
                            table.append(html);

                            $("a").click(function (event) {
                                $(".loading").fadeIn("slow");
                                //setTimeout(function () {
                                //    $(".loading").fadeOut("slow");
                                //}, 200);

                                $(this).blur();
                            });
                        }
                    }
                }
            }

            if (existeAdicional)
                $("#divListaResultado").slideDown();
            else
                $("#divListaResultado").slideUp();

        }

        function carregaAdicionais_old(adicionais) {

            if (adicionais != null) {
                var html = "";

                for (i in adicionais) {

                    var titular = adicionais[i].NumeroCartaoTitular;
                    var bandeira = adicionais[i].NomeBandeira;
                    var produto = adicionais[i].NomeProduto;
                    var adicional = adicionais[i].NumeroCartaoAdicional;
                    var cod = adicionais[i].CodAdicional;

                    var nome = adicionais[i].NomeAdicional;

                    html = "<tr>";
                    html += "   <td style='vertical-align:middle; text-align: center'>" + titular + "</td>";
                    html += "   <td style='vertical-align:middle; text-align: center'>" + bandeira + "</td>";
                    html += "   <td style='vertical-align:middle; text-align: center'>" + produto + "</td>";
                    html += "   <td style='vertical-align:middle; text-align: center'>" + adicional + "</td>";
                    html += "   <td style='vertical-align:middle;'>" + nome + "</td>";
                    html += "   <td style='vertical-align:middle; text-align:center'><a href='Adicional.aspx?operacao=alterar&titular=" + Titular + "&adicional=" + cod + "' class='btn btn-outline btn-primary btn-xs glyphicon glyphicon-edit' data-toggle='tooltip' data-placement='top' title='editar cartão adicional' /> <a href='Adicional.aspx?operacao=consultar&titular=" + Titular + "&adicional=" + cod + "' class='btn btn-outline btn-primary btn-xs glyphicon glyphicon-search' data-toggle='tooltip' data-placement='top' title='consultar cartão adicional' /></td>";
                    html += "</tr>";

                    var table = $("#table-resultado tbody");
                    table.append(html);

                    $("a").click(function (event) {
                        $(".loading").fadeIn("slow");
                        //setTimeout(function () {
                        //    $(".loading").fadeOut("slow");
                        //}, 200);

                        $(this).blur();
                    });
                }
            }
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
    <asp:HiddenField ID="hdnErro" runat="server" Value="" />
    <div class="container">
        <div class="content">
            <div class="row">
                <div class="col-md-12">
                    <h3 class="page-header">
                        Adicionais</h3>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel-body">
                        <div class="row">
                            <div class="panel panel-default">
                            <div class="panel-heading panel-font">
                                Consulta Adicionais
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label class="radio-inline">
                                                <input type="radio" name="optBusca" id="optCPF" value="CPF" checked="checked" />CPF
                                            </label>
                                            <label class="radio-inline">
                                                <input type="radio" name="optBusca" id="optCNPJ" value="CNPJ" />CNPJ
                                            </label>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <%--<asp:Label ID="Label58" runat="server" Text="CPF do Titular:" CssClass="control-label" Height="15" ></asp:Label>--%>
                                            <asp:TextBox ID="txtPesquisa" runat="server" Text="" data-required="true" CssClass="form-control input-numeric"></asp:TextBox>
                                        </div>
                                        <%--<label id="lblErro" runat="server" class="color-red" style="display: none" />--%>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <button type="button" id="btnBuscar" usesubmitbehavior="False" class="btn btn-default">
                                                <i class="fa fa-search"></i> Buscar</button>
                                            <%--<asp:Button ID="btnBuscar" CssClass="btn btn-primary" runat="server" Text="Buscar"
                                        OnClientClick="return consultaTitular()" OnClick="btnBuscar_Click" />--%>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div id="divTitular" class="alert alert-info display-none" style="border-color: #ddd;
                                            background-color: white">
                                            <span id="lblTitular"></span>
                                            <br>
                                            <b><span class="title-msg" id="lblNomeTitular"></span></b>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div id="divListaResultado" class="row display-none">
                                            <div class="col-md-12 bs-glyphicons">
                                                <hr />
                                                <table id="table-resultado" class="table table-hover table-responsive">
                                                    <thead>
                                                        <tr>
                                                            <th style="width: 150px; text-align: center">
                                                                Cartão Titular
                                                            </th>
                                                            <th style="width: 60px; text-align: center">
                                                                Bandeira
                                                            </th>
                                                            <th style="width: 60px; text-align: center">
                                                                Produto
                                                            </th>
                                                            <th style="width: 150px; text-align: center">
                                                                Cartão Adicional
                                                            </th>
                                                            <th style="width: 180px;">
                                                                Nome do Adicional
                                                            </th>
                                                            <th style="width: 50px; text-align: center">
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
                                <div class="row">
                                    <div class="col-md-12 align-center">
                                        <button type="button" id="btnIncluirAdicional" runat="server" class="btn btn-primary">
                                            <i class="fa fa-user"></i>&nbsp; Incluir Adicional</button>
                                    </div>
                                </div>
                            </div>
                        </div>
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
                        Cartão Adicional</h4>
                </div>
                <div class="modal-body align-center" style="font-size: 18px !important;" id="MensagemSucesso">
                    Adicional incluído com sucesso!
                </div>
                <div class="modal-body align-center display-none" id="divMensagemNumeroCartao">
                    <h4>
                        <span class="modal-title text-warning" style="color: #8a6d3b !important; font-size: 18px !important;"
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
                        Cartão Adicional</h4>
                </div>
                <div class="modal-body align-center" style="font-size: 18px !important;">
                    Erro ao realizar operação!
                </div>
                <div class="modal-footer">
                    <button id="Button1" type="button" class="btn btn-danger center-block" data-dismiss="modal">
                        OK</button>
                </div>
            </div>
        </div>
    </div>
    <div class="loading">
    </div>
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


    //    var prm = Sys.WebForms.PageRequestManager.getInstance();
    //    prm.add_endRequest(function () {
    //        CarregaForm();
    //    });

    if ($('#btnIncluir').attr('class') == 'btn btn-primary') {
        $("#divCartoesAdicionais").slideDown();
    }

    var erro = $('[id$=hdnErro]').val();
    if (erro != '') {
        exibePopover($('#txtPesquisa'), erro);
        exibeError($('#txtPesquisa'), true);
    }

</script>
</html>
