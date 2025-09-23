<template>
  <div class="anuncio400-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de Anuncios AS/400</li>
      </ol>
    </nav>
    <h2 class="mb-4">CONSULTA DE ANUNCIOS DEL AS/400</h2>
    <div class="card mb-4">
      <div class="card-body">
        <form @submit.prevent="buscarAnuncio">
          <div class="form-row align-items-end">
            <div class="form-group col-md-4">
              <label for="anuncio">Anuncio:</label>
              <input type="number" v-model="anuncio" class="form-control" id="anuncio" required @keyup.enter="buscarAnuncio" />
            </div>
            <div class="form-group col-md-2">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
      </div>
    </div>

    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>

    <div v-if="anuncioData">
      <h4>Datos del anuncio</h4>
      <table class="table table-sm table-bordered">
        <tbody>
          <tr>
            <th>Recaud</th>
            <td>{{ anuncioData.cvemc }}</td>
            <th>No. Anuncio</th>
            <td>{{ anuncioData.numanu }}</td>
            <th>RFC</th>
            <td>{{ anuncioData.rfc }}</td>
          </tr>
          <tr>
            <th>Nombre Establecimiento</th>
            <td colspan="5">{{ anuncioData.nomesta }}</td>
          </tr>
          <tr>
            <th>Num. Licencia</th>
            <td>{{ anuncioData.numlica }}</td>
            <th>No. Diligencia</th>
            <td>{{ anuncioData.numdili }}</td>
            <th>Ngrupo</th>
            <td>{{ anuncioData.ngrupo }}</td>
          </tr>
          <tr>
            <th>Lsector</th>
            <td>{{ anuncioData.lsector }}</td>
            <th>Ncolon</th>
            <td>{{ anuncioData.ncolon }}</td>
            <th>Ncalle</th>
            <td>{{ anuncioData.ncalle }}</td>
          </tr>
          <tr>
            <th>Lcalle</th>
            <td>{{ anuncioData.lcalle }}</td>
            <th>Tipubic</th>
            <td>{{ anuncioData.tipubic }}</td>
            <th>Nubic</th>
            <td>{{ anuncioData.nubic }}</td>
          </tr>
          <tr>
            <th>Colonia</th>
            <td colspan="5">{{ anuncioData.nomcol }}</td>
          </tr>
          <tr>
            <th>Calle</th>
            <td colspan="5">{{ anuncioData.nomcall }}</td>
          </tr>
          <tr>
            <th>No. Ext</th>
            <td>{{ anuncioData.noext }}</td>
            <th>Letra Ext</th>
            <td>{{ anuncioData.lext }}</td>
            <th>No. Int</th>
            <td>{{ anuncioData.nint }}</td>
          </tr>
          <tr>
            <th>Letra Int</th>
            <td>{{ anuncioData.lint }}</td>
            <th>Empresa</th>
            <td>{{ anuncioData.nempre }}</td>
            <th>Nom. Causante</th>
            <td>{{ anuncioData.nomcau }}</td>
          </tr>
          <tr>
            <th>CRFC</th>
            <td>{{ anuncioData.crfc }}</td>
            <th>Cngrupo</th>
            <td>{{ anuncioData.cngrupo }}</td>
            <th>Clsector</th>
            <td>{{ anuncioData.clsector }}</td>
          </tr>
          <tr>
            <th>CNcolon</th>
            <td>{{ anuncioData.cncolon }}</td>
            <th>CNcalle</th>
            <td>{{ anuncioData.cncalle }}</td>
            <th>Clcalle</th>
            <td>{{ anuncioData.clcalle }}</td>
          </tr>
          <tr>
            <th>CTipubic</th>
            <td>{{ anuncioData.ctipubic }}</td>
            <th>CNubic</th>
            <td>{{ anuncioData.cnubic }}</td>
            <th>CNomcol</th>
            <td>{{ anuncioData.cnomcol }}</td>
          </tr>
          <tr>
            <th>CNomcall</th>
            <td>{{ anuncioData.cnomcall }}</td>
            <th>CNext</th>
            <td>{{ anuncioData.cnext }}</td>
            <th>Clext</th>
            <td>{{ anuncioData.clext }}</td>
          </tr>
          <tr>
            <th>CNint</th>
            <td>{{ anuncioData.cnint }}</td>
            <th>Clint</th>
            <td>{{ anuncioData.clint }}</td>
            <th>Tipanu</th>
            <td>{{ anuncioData.tipanu }}</td>
          </tr>
          <tr>
            <th>Pmetr</th>
            <td>{{ anuncioData.pmetr }}</td>
            <th>Smetr</th>
            <td>{{ anuncioData.smetr }}</td>
            <th>Angrupo</th>
            <td>{{ anuncioData.angrupo }}</td>
          </tr>
          <tr>
            <th>Alsector</th>
            <td>{{ anuncioData.alsector }}</td>
            <th>Ancolon</th>
            <td>{{ anuncioData.ancolon }}</td>
            <th>Ancalle</th>
            <td>{{ anuncioData.ancalle }}</td>
          </tr>
          <tr>
            <th>Alcalle</th>
            <td>{{ anuncioData.alcalle }}</td>
            <th>Anubic</th>
            <td>{{ anuncioData.anubic }}</td>
            <th>Anomcol</th>
            <td>{{ anuncioData.anomcol }}</td>
          </tr>
          <tr>
            <th>Anomcall</th>
            <td>{{ anuncioData.anomcall }}</td>
            <th>Anext</th>
            <td>{{ anuncioData.anext }}</td>
            <th>Alext</th>
            <td>{{ anuncioData.alext }}</td>
          </tr>
          <tr>
            <th>Anint</th>
            <td>{{ anuncioData.anint }}</td>
            <th>Alint</th>
            <td>{{ anuncioData.alint }}</td>
            <th>Zona</th>
            <td>{{ anuncioData.zona }}</td>
          </tr>
          <tr>
            <th>Nzona</th>
            <td>{{ anuncioData.nzona }}</td>
            <th>Nmza</th>
            <td>{{ anuncioData.nmza }}</td>
            <th>Fecha Alta</th>
            <td>{{ anuncioData.fecalt }}</td>
          </tr>
          <tr>
            <th>Feccam</th>
            <td>{{ anuncioData.feccam }}</td>
            <th>Fecbaj</th>
            <td>{{ anuncioData.fecbaj }}</td>
            <th>Nuay1</th>
            <td>{{ anuncioData.nuay1 }}</td>
          </tr>
          <tr>
            <th>Cvpa1</th>
            <td>{{ anuncioData.cvpa1 }}</td>
            <th>Fepa1</th>
            <td>{{ anuncioData.fepa1 }}</td>
            <th>Rein1</th>
            <td>{{ anuncioData.rein1 }}</td>
          </tr>
          <tr>
            <th>Recl1</th>
            <td>{{ anuncioData.recl1 }}</td>
            <th>Nuof1</th>
            <td>{{ anuncioData.nuof1 }}</td>
            <th>Impe1</th>
            <td>{{ anuncioData.impe1 }}</td>
          </tr>
          <tr>
            <th>Imiv1</th>
            <td>{{ anuncioData.imiv1 }}</td>
            <th>Pdpa1</th>
            <td>{{ anuncioData.pdpa1 }}</td>
            <th>Nuct1</th>
            <td>{{ anuncioData.nuct1 }}</td>
          </tr>
          <tr>
            <th>Nuay2</th>
            <td>{{ anuncioData.nuay2 }}</td>
            <th>Cvpa2</th>
            <td>{{ anuncioData.cvpa2 }}</td>
            <th>Fepa2</th>
            <td>{{ anuncioData.fepa2 }}</td>
          </tr>
          <tr>
            <th>Rein2</th>
            <td>{{ anuncioData.rein2 }}</td>
            <th>Recl2</th>
            <td>{{ anuncioData.recl2 }}</td>
            <th>Nuof2</th>
            <td>{{ anuncioData.nuof2 }}</td>
          </tr>
          <tr>
            <th>Impe2</th>
            <td>{{ anuncioData.impe2 }}</td>
            <th>Imiv2</th>
            <td>{{ anuncioData.imiv2 }}</td>
            <th>Pdpa2</th>
            <td>{{ anuncioData.pdpa2 }}</td>
          </tr>
          <tr>
            <th>Nuct2</th>
            <td>{{ anuncioData.nuct2 }}</td>
            <th>Nuay3</th>
            <td>{{ anuncioData.nuay3 }}</td>
            <th>Cvpa3</th>
            <td>{{ anuncioData.cvpa3 }}</td>
          </tr>
          <tr>
            <th>Fepa3</th>
            <td>{{ anuncioData.fepa3 }}</td>
            <th>Rein3</th>
            <td>{{ anuncioData.rein3 }}</td>
            <th>Recl3</th>
            <td>{{ anuncioData.recl3 }}</td>
          </tr>
          <tr>
            <th>Nuof3</th>
            <td>{{ anuncioData.nuof3 }}</td>
            <th>Impe3</th>
            <td>{{ anuncioData.impe3 }}</td>
            <th>Imiv3</th>
            <td>{{ anuncioData.imiv3 }}</td>
          </tr>
          <tr>
            <th>Pdpa3</th>
            <td>{{ anuncioData.pdpa3 }}</td>
            <th>Nuct3</th>
            <td>{{ anuncioData.nuct3 }}</td>
            <th>Fut1</th>
            <td>{{ anuncioData.fut1 }}</td>
          </tr>
          <tr>
            <th>Fut2</th>
            <td>{{ anuncioData.fut2 }}</td>
          </tr>
        </tbody>
      </table>
      <router-link :to="'/anuncio400/' + anuncio + '/pagos'" class="btn btn-secondary mt-3">Ver Pagos</router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Anuncio400Page',
  data() {
    return {
      anuncio: '',
      anuncioData: null,
      loading: false,
      error: null
    };
  },
  methods: {
    async buscarAnuncio() {
      this.error = null;
      this.anuncioData = null;
      if (!this.anuncio) {
        this.error = 'Debe ingresar el número de anuncio.';
        return;
      }
      this.loading = true;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'getAnuncio400',
            params: { anuncio: this.anuncio }
          })
        });
        const data = await response.json();
        if (data.eResponse.success && data.eResponse.data.length > 0) {
          this.anuncioData = data.eResponse.data[0];
        } else {
          this.error = data.eResponse.error || 'No se encontró el anuncio.';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.anuncio400-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
