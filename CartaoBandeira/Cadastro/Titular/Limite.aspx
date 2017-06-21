<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="Limite.aspx.cs"
    Inherits="Limite" %>
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

    <link rel="stylesheet" type="text/css" href="../../css/cssLimite.css" />

    <script language="javascript" type="text/javascript" src="../../js/jquery-3.1.1.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.mask.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.maskMoney.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/bootstrap.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/metisMenu/metisMenu.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/sb-admin-2.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/default.js"></script>
    <script language="javascript" type="text/javascript">

        var UsuarioTitular = "";

        $(document).ready(function () {

            $('#txtLimiteConta').keyup(function (e) {
                UsuarioTitular.Conta.LimiteDaConta = retornaFloat($(this).val());
                calculaLimites();

                if ($(this).val() == "" | $(this).val() == "0,00") {
                    $("#btnConfirmar").addClass("disabled");
                }

            });

            $('#txtLimiteConta').focusout(function (e) {

                if ($(this).val() == "" | $(this).val() == "0,00") {
                    setTimeout(function () { exibeCampoObrigatorio($('#txtLimiteConta')); }, 100);
                }

            });

            $("#ddlNumeroCartaoTitular").change(function () {

                if ($(this).val() == "") {
                    $('#divLimitesProduto').slideUp();
                    $('#divLimitesProdutoAdicional').slideUp();
                    $("#table-limites tbody tr").remove();
                    $("#txtLimiteProduto").val("");

                    $("#table-limites-adicional tbody tr").remove();
                    $('#divNomeAdicional').fadeOut("slow");
                    $('#divListaLimitesAdicional').slideUp();

                    return;
                }

                carregaLimiteCartaoTitular($(this).val());

            });

            $("#ddlNumeroCartaoAdicional").change(function () {

                if ($(this).val() == "") {
                    //$("#txtLimiteProduto").val("");
                    $('#divNomeAdicional').fadeOut("slow");
                    $('#divListaLimitesAdicional').slideUp();
                    return;
                }

                var cartaoAdicional = ObtemCartaoAdicional();

                if (cartaoAdicional != null) {

                    $('#divNomeAdicional').fadeIn("slow");
                    $('#txtNomeAdicional').val(cartaoAdicional.NomeCompleto);

                    $("#table-limites-adicional tbody tr").remove();

                    if (cartaoAdicional.Limites.length > 0) {

                        $.each(cartaoAdicional.Limites, function (index, item) {
                            var html = '' +
                        "<tr>" +
                            "<th style='width: 200px; text-align:right; padding-top:15px; font-weight:normal'>" +
                            "<span> nomeLimite: </span>" +
                            "</th>" +
                            "<th style='font-weight:normal'><div class='form-group'><div class='input-group'><span class='input-group-addon'>codTipoValorLimite</span>" +
                                "<input type=text id='valorLimiteAdicional' value='dadosLimiteAdicional' data-cod_limite='codLimiteAdicional' data-cod_tipo_limite='codTipoLimiteAdicional' data-cod_conta='codContaAdicional' data-cod_produto='codProdutoAdicional' class='form-control' placeholder='Valor' style='width:80px;'/><span id='infoItemLimiteAdicional' style='width:100%' class='input-group-addon align-left'>R$ 0,00</span>" +
                            "</div></div></th>" +
                        "</tr>";

                            html = html.replace('codTipoValorLimite', '%')

                            html = html.replace('nomeLimite', item.NomeLimite)
                                    .replace('codLimiteAdicional', item.CodLimite)
                                    .replace('dadosLimiteAdicional', item.ValorLimite)
                                    .replace('codTipoLimiteAdicional', item.CodTipoLimite)
                                    .replace('codContaAdicional', item.CodConta)
                                    .replace('codProdutoAdicional', item.CodProduto)
                                    .replace('valorLimiteAdicional', 'valorLimiteAdicional' + item.CodTipoLimite)
                                    .replace('infoItemLimiteAdicional', 'infoItemLimiteAdicional' + item.CodTipoLimite);

                            var table = $("#table-limites-adicional tbody");
                            table.append(html);

                            $('[id*=valorLimiteAdicional]').unmask();
                            $('[id*=valorLimiteAdicional]').mask('999', { placeholder: 'Valor' });

                            if (item.ValorLimite === "")
                                exibeError($('#valorLimiteAdicional' + item.CodTipoLimite), true);

                        });

                        calculaLimites();

                        $('#divListaLimitesAdicional').slideDown();
                    }

                }

                $('[id*=valorLimiteAdicional]').focusout(function (e) {
                    if ($(this).val().trim() != "") {
                        $(this).val(parseInt($(this).val()));
                    }
                    else
                        exibeCampoObrigatorio($(this));
                });


                $('[id*=valorLimiteAdicional]').keyup(function (e) {
                    exibeError($(this), false);

                    var limites = $('[id*=valorLimiteAdicional]');
                    for (var i = 0; i < limites.length; i++) {
                        var item = $(limites[i]);
                        if (item.val().trim() != "") {
                            exibeError(item, false);
                        }
                    }

                    if ($('#txtLimiteProduto').val().trim() != "") {
                        exibeError($('#txtLimiteProduto'), false);
                    }

                    //var id = $(this).context.id.replace('valorLimite', '');
                    var id = $(this)[0].id.replace('valorLimiteAdicional', '');

                    var totalProduto = 0.0;
                    if ($('#txtLimiteProduto').val().trim() != "")
                        totalProduto = retornaFloat($('#txtLimiteProduto').val());

                    var valor = totalProduto * $(this).val() / 100;
                    $('#infoItemLimiteAdicional' + id).text('R$ ' + retornaValor(valor));

                    var cartaoAdicional = ObtemCartaoAdicional();
                    var codLimite = $(this).attr('data-cod_limite');
                    var limite = cartaoAdicional.Limites.filter(function (item) {
                        if (item.CodLimite == codLimite) {
                            return item;
                        }
                    });
                    limite = limite[0];
                    limite.ValorLimite = $(this).val();

                    if ($(this).val() != "")
                        limite.ValorLimite = parseInt($(this).val());

                    calculaLimites();

                });

                $("[id*=valorLimiteAdicional]").keypress(function (event) {
                    var code = event.charCode || event.keyCode;
                    if (isKeyNumeric(event)) {
                        var value = this.value + event.key;
                        if (this.selectionStart == 0)
                            value = event.key + this.value.toString();

                        if (value > 100)
                            return false;
                    }
                    else
                        return false;
                });

            });

        });

        function carregaLimiteCartaoTitular(codCartao) {
            $('#divLimitesProduto').slideUp();
            $('#divLimitesProdutoAdicional').slideUp();
            $("#table-limites tbody tr").remove();

            $('#divNomeAdicional').fadeOut("slow");
            $('#divListaLimitesAdicional').slideUp();
            $("#table-limites-adicional tbody tr").remove();

            var cartaoTitular = ObtemCartaoTitular(codCartao);

            if (cartaoTitular.Limites.length > 0) {
                $.each(cartaoTitular.Limites, function (index, item) {

                    var html = '' +
                "<tr>" +
                    "<th style='width: 200px; text-align:right; padding-top:15px; font-weight:normal'>" +
                    "<span> nomeLimite: </span>" +
                    "</th>" +
                    "<th style='font-weight:normal'><div class='form-group'><div class='input-group'><span class='input-group-addon'>codTipoValorLimite</span>" +
                        "<input type=text id='valorLimite' value='dadosLimite' data-cod_limite='codLimite' data-cod_tipo_limite='codTipoLimite' data-cod_conta='codConta' data-cod_produto='codProduto' maxlength='10' class='form-control' placeholder='Valor' style='width:80px;'/><span id='infoItemLimite' style='width:100%' class='input-group-addon align-left'>R$ 0,00</span>" +
                    "</div></div></th>" +
                "</tr>";

                    html = html.replace('codTipoValorLimite', '%')

                    html = html.replace('nomeLimite', item.NomeLimite)
                            .replace('codLimite', item.CodLimite)
                            .replace('dadosLimite', item.ValorLimite)
                            .replace('codTipoLimite', item.CodTipoLimite)
                            .replace('codConta', item.CodConta)
                            .replace('codProduto', item.CodProduto)
                            .replace('valorLimite', 'valorLimite' + item.CodTipoLimite)
                            .replace('infoItemLimite', 'infoItemLimite' + item.CodTipoLimite);

                    var table = $("#table-limites tbody");
                    table.append(html);

                    $('[id*=valorLimite]').unmask();
                    $('[id*=valorLimite]').mask('999', { placeholder: 'Valor' });

                    if (item.ValorLimite === "")
                        exibeError($('#valorLimite' + item.CodTipoLimite), true);
                });

                var valorLimiteProduto = retornaValor(ObtemLimiteProduto(codCartao));
                if (valorLimiteProduto == "0,00")
                    exibeError($('#txtLimiteProduto'), true);
                else
                    exibeError($('#txtLimiteProduto'), false);

                $("#txtLimiteProduto").val(valorLimiteProduto);

                $('#divLimitesProduto').slideDown();

            }

            if (cartaoTitular.Adicional != null && cartaoTitular.Adicional.length > 0) {

                $('#divLimitesProdutoAdicional').slideDown();

                $('#ddlNumeroCartaoAdicional').empty();
                $('#ddlNumeroCartaoAdicional').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                $.each(cartaoTitular.Adicional, function (index, item) {
                    var value = item.CartaoAdicional.CodCartao;
                    var text = item.CartaoAdicional.NumeroCartao + ' - ' + item.CartaoAdicional.NomeBandeira + ' - ' + item.CartaoAdicional.NomeProduto;
                    $('#ddlNumeroCartaoAdicional').append($('<option>', { value: value, text: text }, '</option>'));
                });
            }
            else {
                $('#divLimitesProdutoAdicional').slideUp();
            }

            $('[id*=valorLimite]').focusout(function (e) {
                if ($(this).val().trim() != "") {
                    $(this).val(parseInt($(this).val()));
                }
                else
                    exibeCampoObrigatorio($(this));

            });

            $('[id*=valorLimite]').keyup(function (e) {
                exibeError($(this), false);

                var limites = $('[id*=valorLimite]');
                for (var i = 0; i < limites.length; i++) {
                    var item = $(limites[i]);
                    if (item.val().trim() != "") {
                        exibeError(item, false);
                    }
                }

                if ($('#txtLimiteProduto').val().trim() != "") {
                    exibeError($('#txtLimiteProduto'), false);
                }

                //var id = $(this).context.id.replace('valorLimite', '');
                var id = $(this)[0].id.replace('valorLimite', '');

                var totalProduto = 0.0;
                if ($('#txtLimiteProduto').val().trim() != "")
                    totalProduto = retornaFloat($('#txtLimiteProduto').val());

                var valor = totalProduto * $(this).val() / 100;
                $('#infoItemLimite' + id).text('R$ ' + retornaValor(valor));

                var cartaoTitular = ObtemCartaoTitular();
                var codLimite = $(this).attr('data-cod_limite');
                var limite = cartaoTitular.Limites.filter(function (item) {
                    if (item.CodLimite == codLimite) {
                        return item;
                    }
                });
                limite = limite[0];
                limite.ValorLimite = $(this).val();

                if ($(this).val() != "")
                    limite.ValorLimite = parseInt($(this).val());

                calculaLimites();

            });

            $("[id*=valorLimite]").keypress(function (event) {
                var code = event.charCode || event.keyCode;
                if (isKeyNumeric(event)) {
                    var value = this.value + event.key;
                    if (this.selectionStart == 0)
                        value = event.key + this.value.toString();

                    if (value > 100)
                        return false;
                }
                else
                    return false;
            });

            $('#txtLimiteProduto').keyup(function (e) {
                exibeError($(this), false);

                var limites = $('[id*=valorLimite]');
                for (var i = 0; i < limites.length; i++) {
                    var item = $(limites[i]);
                    if (item.val().trim() != "") {
                        exibeError(item, false);
                    }
                }

                //var cartaoTitular = ObtemCartaoTitular();
                //cartaoTitular.LimiteProduto = retornaFloat($(this).val());

                var contaProduto = ObtemContaProduto();
                contaProduto.LimiteProduto = retornaFloat($(this).val());
                contaProduto.Cartao.LimiteProduto = contaProduto.LimiteProduto

                calculaLimites();

            });

            $('#txtLimiteProduto').focusout(function (e) {
                if ($(this).val() == "" || $(this).val() == "0,00") {
                    setTimeout(function () { exibeCampoObrigatorio($('#txtLimiteProduto')); }, 100);
                }

            });

            calculaLimites();

        }

        //        function carregaListaLimiteProduto(codConta, codProduto, codAdicional) {
        //            $('#divLimitesProduto').slideUp();
        //            $('#divLimitesProdutoAdicional').slideUp();

        //            $("#table-limites tbody tr").remove();

        //            var param = JSON.stringify({
        //                codConta: codConta,
        //                codProduto: codProduto,
        //                codAdicional: codAdicional,
        //            });

        //            $.ajax({
        //                type: "POST",
        //                contentType: "application/json; charset=utf-8",
        //                url: 'Limite.aspx/ObterDadosLimiteProduto',
        //                data: param,
        //                dataType: "json",
        //                async: true,
        //                success: function (response) {
        //                    var jsonResult = response.d;

        //                    if (jsonResult != null && jsonResult.length > 0) {

        //                        $.each(jsonResult, function (index, item) {

        //                            var html = '' +
        //                            "<tr>" +
        //                                "<th style='width: 200px; text-align:right; padding-top:15px; font-weight:normal'>" +
        //                                "<span> nomeLimite: </span>" +
        //                                "</th>" +
        //                                "<th style='font-weight:normal'><div class='form-group'><div class='input-group'><span class='input-group-addon'>codTipoValorLimite</span>" +
        //                                    "<input type=text id='valorLimite' value='dadosLimite' data-cod_limite='codLimite' data-cod_tipo_limite='codTipoLimite' data-cod_conta='codConta' data-cod_produto='codProduto' maxlength='10' class='form-control' placeholder='Valor' style='width:80px;'/><span id='infoItemLimite' style='width:100%' class='input-group-addon align-left'>R$ 0,00</span>" +
        //                                "</div></div></th>" +
        //                            "</tr>";

        //                            html = html.replace('codTipoValorLimite', '%')

        //                            html = html.replace('nomeLimite', item.NomeLimite)
        //                                       .replace('codLimite', item.CodLimite)
        //                                       .replace('dadosLimite', item.ValorLimite)
        //                                       .replace('codTipoLimite', item.CodTipoLimite)
        //                                       .replace('codConta', codConta)
        //                                       .replace('codProduto', codProduto)
        //                                       .replace('valorLimite', 'valorLimite' + item.CodTipoLimite)
        //                                       .replace('infoItemLimite', 'infoItemLimite' + item.CodTipoLimite);

        //                            var table = $("#table-limites tbody");
        //                            table.append(html);

        //                            $('[id*=valorLimite]').unmask();
        //                            $('[id*=valorLimite]').mask('999', { placeholder: 'Valor' });

        //                        });

        //                        $('[id*=valorLimite]').focusout(function (e) {
        //                            if ($(this).val().trim() != "") {
        //                                $(this).val(parseInt($(this).val()));
        //                            }
        //                        });


        //                        $('[id*=valorLimite]').keyup(function (e) {
        //                            exibeError($(this), false);

        //                            var limites = $('[id*=valorLimite]');
        //                            for (var i = 0; i < limites.length; i++) {
        //                                var item = $(limites[i]);
        //                                if (item.val().trim() != "") {
        //                                    exibeError(item, false);
        //                                }
        //                            }

        //                            if ($('#txtLimiteProduto').val().trim() != "") {
        //                                exibeError($('#txtLimiteProduto'), false);
        //                            }

        //                            //var id = $(this).context.id.replace('valorLimite', '');
        //                            var id = $(this)[0].id.replace('valorLimite', '');

        //                            var totalProduto = 0.0;
        //                            if ($('#txtLimiteProduto').val().trim() != "")
        //                                totalProduto = retornaFloat($('#txtLimiteProduto').val());

        //                            var valor = totalProduto * $(this).val() / 100;
        //                            $('#infoItemLimite' + id).text('R$ ' + retornaValor(valor));

        //                        });

        //                        $("[id*=valorLimite]").keypress(function (event) {
        //                            var code = event.charCode || event.keyCode;
        //                            if (isKeyNumeric(event)) {
        //                                // permitimos somente números
        //                                var value = this.value + event.key;

        //                                if (value > 100)
        //                                    return false;
        //                            }
        //                            else
        //                                return false;
        //                        });

        //                        $('#txtLimiteProduto').keyup(function (e) {
        //                            exibeError($(this), false);

        //                            var limites = $('[id*=valorLimite]');
        //                            for (var i = 0; i < limites.length; i++) {
        //                                var item = $(limites[i]);
        //                                if (item.val().trim() != "") {
        //                                    exibeError(item, false);
        //                                }
        //                            }

        //                            calculaLimites();

        //                        });

        //                        calculaLimites();

        //                        //var limites = $('[id*=valorLimite]');
        //                        //for (var i = 0; i < limites.length; i++) {
        //                        //    var item = $(limites[i]);
        //                        //    item.attr("disabled", "disabled");
        //                        //}
        //                        
        //                        $('#divLimitesProduto').slideDown();
        //                        $('#divLimitesProdutoAdicional').slideDown();

        //                    };

        //                },
        //                error: function (response) {
        //                    $(".loading").fadeOut("slow");
        //                    //$('#modalError').modal('show');
        //                    window.location.href = "../../Erro.aspx";
        //                }

        //            });
        //        }

        // método responsável por validar os campos do form
        function validaFormulario() {
            $(".loading").fadeIn("slow");

            $('input#hdnTitular').val(JSON.stringify(UsuarioTitular));

            return true;
        }

        function calculaLimites() {

            var totalProduto = 0.0;
            var totalLimitesProduto = 0.0;
            var validaLimiteProduto = true;

            //$("#txtLimiteProduto").val(retornaValor(ObtemLimiteProduto(codCartao)));

            if ($('#txtLimiteProduto').val().trim() != "") {
                totalProduto = retornaFloat($('#txtLimiteProduto').val());
            }

            var limites = $('[id*=valorLimite]');
            for (var i = 0; i < limites.length; i++) {
                var item = $(limites[i]);

                if (item.val().trim() != "") {

                    var id = item[0].id.replace('valorLimite', '');
                    var valor = totalProduto * item.val() / 100;

                    $('#infoItemLimite' + id).text('R$ ' + retornaValor(valor));

                }
                else {
                    validaLimiteProduto = false;
                }

            }

            var limites = $('[id*=valorLimiteAdicional]');
            for (var i = 0; i < limites.length; i++) {
                var item = $(limites[i]);

                if (item.val().trim() != "") {

                    var id = item[0].id.replace('valorLimiteAdicional', '');
                    var valor = totalProduto * item.val() / 100;

                    $('#infoItemLimiteAdicional' + id).text('R$ ' + retornaValor(valor));

                }
                else {
                    validaLimiteProduto = false;
                }
            }

            var limiteTotalConta = 0.0;
            var limiteTotalProduto = 0.0;

            if (UsuarioTitular.Conta.LimiteDaConta != "")
                limiteTotalConta = UsuarioTitular.Conta.LimiteDaConta;

            $.each(UsuarioTitular.Conta.ContaProduto, function (index, item) {
                if (item.LimiteProduto == 0) {
                    validaLimiteProduto = false;
                }

                if ( item.CodStatusContaProduto != 3 && item.Cartao.CodStatusCartao != 3) {
                    limiteTotalProduto += item.LimiteProduto;
                }

            });

            var valorTotal = retornaValor(limiteTotalConta - limiteTotalProduto);
            if (retornaFloat(valorTotal) > 0) {
                $('#lblLimiteDisponivelConta').attr('class', 'control-label color-green')
                $('#spnLimiteDisponivelConta').attr('class', 'input-group-addon alert-success')
                $('#txtLimiteDisponivelConta').attr('class', 'form-control alert-success')
            }
            else {
                $('#lblLimiteDisponivelConta').attr('class', 'control-label color-red')
                $('#spnLimiteDisponivelConta').attr('class', 'input-group-addon alert-danger')
                $('#txtLimiteDisponivelConta').attr('class', 'form-control alert-danger')
            }

            $('#txtLimiteDisponivelConta').text(valorTotal);

            if (retornaFloat(valorTotal) < 0 || !validaLimiteProduto)
                $("#btnConfirmar").addClass("disabled");
            else
                $("#btnConfirmar").removeClass("disabled");

        }

        function ObtemLimiteProduto(codCartao) {

            var cartaoTitular = UsuarioTitular.Conta.ContaProduto.filter(function (item) {
                if (item.Cartao.CodCartao == codCartao) {
                    return item;
                }
            });

            return cartaoTitular[0].LimiteProduto;

        }

        function ObtemCartaoTitular(codCartao) {

            if (codCartao === undefined)
                codCartao = $('#ddlNumeroCartaoTitular option:selected').val();

            var cartaoTitular = UsuarioTitular.Conta.ContaProduto.filter(function (item) {
                if (item.Cartao.CodCartao == codCartao) {
                    return item;
                }
            });

            return cartaoTitular[0].Cartao;

        }

        function ObtemContaProduto(codCartao) {

            if (codCartao === undefined)
                codCartao = $('#ddlNumeroCartaoTitular option:selected').val();

            var cartaoTitular = UsuarioTitular.Conta.ContaProduto.filter(function (item) {
                if (item.Cartao.CodCartao == codCartao) {
                    return item;
                }
            });

            return cartaoTitular[0];

        }

        function ObtemCartaoAdicional(codCartaoAdicional) {

            var cartaoTitular = ObtemCartaoTitular();

            if (cartaoTitular.Adicional != null) {

                if (codCartaoAdicional === undefined)
                    codCartaoAdicional = $('#ddlNumeroCartaoAdicional option:selected').val();

                var cartaoAdicional = cartaoTitular.Adicional.filter(function (item) {
                    if (item.CartaoAdicional.CodCartao == codCartaoAdicional) {
                        return item;
                    }
                });

                return cartaoAdicional[0].CartaoAdicional;
            }

            return null;
        }

    </script>
</head>
<body class="fadeIn">
    <form id="form1" autocomplete="off" runat="server">
    <asp:ScriptManager runat="server">
    </asp:ScriptManager>
    <asp:HiddenField ID="hdnOperacao" runat="server" Value="" />
    <asp:HiddenField ID="hdnTitular" runat="server" Value="" />
    <div class="container">
        <div class="content">
            <div class="row">
                <div class="col-md-12">
                    <h3 id="divTitulo" class="page-header">
                        Limites do Cartão</h3>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel-body">
                        <div class="row row-margin">
                            <div id="dados-cartao" class="panel panel-default">
                                <div class="panel-heading panel-font">
                                    Dados de Limites do Cartão
                                </div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <asp:Label ID="lblCpfCnpj" runat="server" Text="CPF/CNPJ:" CssClass="control-label"></asp:Label>
                                                <asp:Label ID="lblCpfCnpjTitular" runat="server" CssClass="control-label-box-default"> </asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <asp:Label ID="lbNome" runat="server" Text="Nome:" CssClass="control-label"></asp:Label>
                                                <asp:Label ID="lblNomeTitular" runat="server" CssClass="control-label-box-default"> </asp:Label>
                                            </div>
                                        </div>
                                    </div>
                                    <hr />
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <asp:Label ID="Label1" runat="server" Text="Número do Cartão do Titular:" CssClass="control-label"></asp:Label>
                                                <asp:DropDownList ID="ddlNumeroCartaoTitular" runat="server" CausesValidation="True"
                                                    data-required="true" CssClass="form-control">
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <asp:Label ID="lblRenda" runat="server" Text="Renda Mensal:" CssClass="control-label"></asp:Label>
                                                <div class="input-group">
                                                    <span class="input-group-addon">R$</span>
                                                    <asp:TextBox ID="txtRendaMensal" runat="server" MaxLength="15" Width="150" placeholder="Renda mensal"
                                                        data-required="true" CssClass="form-control input-money" disabled></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <asp:Label ID="Label4" runat="server" Text="Limite Total da Conta:" CssClass="control-label"></asp:Label>
                                                <div class="input-group">
                                                    <span class="input-group-addon">R$</span>
                                                    <asp:TextBox ID="txtLimiteConta" runat="server" MaxLength="15" Width="150" placeholder="Limite da conta"
                                                        data-required="true" CssClass="form-control input-money"></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <asp:Label ID="lblLimiteDisponivelConta" runat="server" Text="Limite Disponível da Conta:"
                                                    CssClass="control-label"></asp:Label>
                                                <div class="input-group">
                                                    <span id="spnLimiteDisponivelConta" class="input-group-addon">R$</span>
                                                    <asp:Label ID="txtLimiteDisponivelConta" runat="server" Width="150" placeholder="Limite total disponível da conta"
                                                        data-required="true" CssClass="form-control"></asp:Label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row display-none" id="divLimitesProduto">
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <asp:Label ID="Label17" runat="server" Text="Limite Total do Produto:" CssClass="control-label"></asp:Label>
                                                <div class="input-group">
                                                    <span class="input-group-addon">R$</span>
                                                    <asp:TextBox ID="txtLimiteProduto" runat="server" MaxLength="15" placeholder="Limite total do produto"
                                                        data-required="true" CssClass="form-control input-money"></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-6 bs-glyphicons">
                                            <asp:Label ID="Label16" runat="server" Text="Limites do Produto:" CssClass="control-label"></asp:Label>
                                            <%--<div class="display-none" id="divLimitesProduto">--%>
                                            <asp:HiddenField ID="hdnListaLimites" runat="server" Value="" />
                                            <table id="table-limites" class="table table-hover">
                                                <tbody>
                                                </tbody>
                                            </table>
                                            <%--</div>--%>
                                        </div>
                                    </div>
                                    <div class="row row-margin display-none" id="divLimitesProdutoAdicional">
                                        <div class="panel panel-default">
                                            <div class="panel-heading panel-font">
                                                Dados de Limites do Cartão Adicional
                                            </div>
                                            <div class="panel-body">
                                                <div class="row">
                                                    <div class="col-md-6">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label2" runat="server" Text="Número do Cartão do Adicional:" CssClass="control-label"></asp:Label>
                                                            <asp:DropDownList ID="ddlNumeroCartaoAdicional" runat="server" CausesValidation="True"
                                                                data-required="true" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div id="divNomeAdicional" class="col-md-6 bs-glyphicons display-none">
                                                        <asp:Label ID="Label5" runat="server" Text="Nome do Adicional:" CssClass="control-label"></asp:Label>
                                                        <asp:TextBox ID="txtNomeAdicional" runat="server" placeholder="Nome do adicional"
                                                            data-required="true" CssClass="form-control" disabled></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="row">
                                                    <div id="divListaLimitesAdicional" class="col-md-6 bs-glyphicons display-none">
                                                        <asp:Label ID="Label3" runat="server" Text="Limites do Produto Adicional:" CssClass="control-label"></asp:Label>
                                                        <asp:HiddenField ID="hdnListaLimitesAdicional" runat="server" Value="" />
                                                        <table id="table-limites-adicional" class="table table-hover">
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
                        </div>
                        <div class="row align-center">
                            <asp:LinkButton ID="btnConfirmar" CssClass="btn btn-primary" runat="server" OnClientClick="javascript:return validaFormulario();"
                                OnClick="btnConfirmar_Click">Confirmar <i class="fa fa-check"></i></asp:LinkButton>
                        </div>
                        <div class="row">
                            <div class="col-md-12">
                                <a type="button" href="MenuTitular.aspx" id="btnVoltar" runat="server" class="btn btn-link">
                                    Voltar</a>
                            </div>
                        </div>
                    </div>
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
    <div class="loading">
    </div>
    </form>
</body>
<script language="javascript" type="text/javascript">

    var operacao = $('[id$=hdnOperacao]').val();
    if (operacao == "AlterarSucesso") {
        $("#MensagemSucesso").text('Limite do Cartão alterado com sucesso!')
        $("#modalMensagem").modal("show");
    }
    else if (operacao == "Erro") {
        $("#modalErro").modal("show");
    }
    $('[id$=hdnOperacao]').val('');

    UsuarioTitular = $.parseJSON($('[id$=hdnTitular]').val());
    calculaLimites();

</script>
</html>
