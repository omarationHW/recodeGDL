<template>
  <div class="dictamenfrm-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Dictamen de Anuncio</li>
      </ol>
    </nav>
    <div class="card mb-4">
      <div class="card-header">
        <h3>DICTAMEN DE ANUNCIO</h3>
      </div>
      <div class="card-body">
        <form @submit.prevent="buscarAnuncio">
          <div class="form-group row">
            <label for="anuncio" class="col-sm-2 col-form-label font-weight-bold">No. Anuncio</label>
            <div class="col-sm-4">
              <input type="number" v-model="anuncio" id="anuncio" class="form-control" required />
            </div>
            <div class="col-sm-4">
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" id="tipoProcedente" value="1" v-model="tipo" />
                <label class="form-check-label" for="tipoProcedente">Procedente</label>
              </div>
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" id="tipoImprocedente" value="0" v-model="tipo" />
                <label class="form-check-label" for="tipoImprocedente">Improcedente</label>
              </div>
            </div>
            <div class="col-sm-2">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
      </div>
    </div>
    <div v-if="anuncioData" class="card mb-4">
      <div class="card-header">
        <h5>Datos del Anuncio</h5>
      </div>
      <div class="card-body">
        <table class="table table-bordered table-sm">
          <tbody>
            <tr>
              <th>Propietario</th>
              <td>{{ anuncioData.propietarionvo }}</td>
              <th>Ubicación</th>
              <td>{{ anuncioData.ubicacion }} #{{ anuncioData.numext_ubic }}{{ anuncioData.letraext_ubic }} Int. {{ anuncioData.numint_ubic }}{{ anuncioData.letraint_ubic }}, Col. {{ anuncioData.colonia_ubic }}, CP {{ anuncioData.cp }}</td>
            </tr>
            <tr>
              <th>Trámite Solicitada</th>
              <td colspan="3">FACTIBILIDAD DE INSTALACION DE ANUNCIO</td>
            </tr>
            <tr>
              <th>Descripción</th>
              <td colspan="3">{{ anuncioData.descripcion }}</td>
            </tr>
            <tr>
              <th>Clasificación</th>
              <td>{{ anuncioData.clasificacion }}</td>
              <th>Vistas</th>
              <td>{{ anuncioData.num_caras }}</td>
            </tr>
            <tr>
              <th>Medidas</th>
              <td>{{ anuncioData.medidas1 }} x {{ anuncioData.medidas2 }}</td>
              <th>Área</th>
              <td>{{ anuncioData.area_anuncio }}</td>
            </tr>
          </tbody>
        </table>
        <button class="btn btn-success" @click="imprimirReporte">Imprimir Dictamen</button>
      </div>
    </div>
    <div v-if="pdfUrl" class="alert alert-info">
      <a :href="pdfUrl" target="_blank">Descargar Dictamen PDF</a>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DictamenFrmPage',
  data() {
    return {
      anuncio: '',
      tipo: '1',
      anuncioData: null,
      error: '',
      pdfUrl: ''
    };
  },
  methods: {
    async buscarAnuncio() {
      this.error = '';
      this.anuncioData = null;
      this.pdfUrl = '';
      if (!this.anuncio) {
        this.error = 'Debe ingresar el número de anuncio';
        return;
      }
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'dictamenfrm.getAnuncio',
            params: { anuncio: this.anuncio }
          })
        });
        const data = await response.json();
        if (data.eResponse.success && data.eResponse.data.length > 0) {
          this.anuncioData = data.eResponse.data[0];
        } else {
          this.error = data.eResponse.error || 'No se encontró el anuncio';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor';
      }
    },
    async imprimirReporte() {
      if (!this.anuncioData) return;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'dictamenfrm.printReport',
            params: { anuncio: this.anuncio, tipo: this.tipo }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.pdfUrl = data.eResponse.data.pdf_url;
        } else {
          this.error = data.eResponse.error || 'No se pudo generar el reporte';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor';
      }
    }
  }
};
</script>

<style scoped>
.dictamenfrm-page {
  max-width: 900px;
  margin: 0 auto;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
.card-header {
  background: #e9ecef;
}
</style>
