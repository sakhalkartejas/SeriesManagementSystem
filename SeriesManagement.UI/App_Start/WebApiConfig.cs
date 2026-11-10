using System.Web.Http;
using Newtonsoft.Json.Serialization;

namespace SeriesManagement.UI
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new
                {
                    id = RouteParameter.Optional
                }
            );

            var json = config.Formatters.JsonFormatter;
            json.SerializerSettings.ContractResolver = new DefaultContractResolver();
            config.Formatters.Remove(config.Formatters.XmlFormatter);
        }
    }
}
