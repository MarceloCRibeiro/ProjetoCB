using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

public class JsonResult
{
    public bool Resposta { get; set; }
    public bool Erro { get; set; }
    public string Mensagem { get; set; }
    public object Resultado { get; set; }

    public JsonResult()
	{

	}
    
}