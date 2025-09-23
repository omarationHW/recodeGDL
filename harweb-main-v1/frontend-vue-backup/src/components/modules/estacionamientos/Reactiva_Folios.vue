<template>
  <div class="reactiva-folios-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reactivar Folios</li>
      </ol>
    </nav>
    <h2>Reactivar Folios</h2>
    <div class="card p-4 mb-3">
      <div class="form-group mb-3">
        <label>Buscar por:</label>
        <div>
          <label class="me-3">
            <input type="radio" value="0" v-model="opcion" /> Por Placa y Folio
          </label>
          <label>
            <input type="radio" value="1" v-model="opcion" /> Por Año y Folio
          </label>
        </div>
      </div>
      <div class="row mb-3">
        <div class="col-md-3" v-if="opcion == 0">
          <label for="placa">Placa</label>
          <input id="placa" v-model="placa" class="form-control" maxlength="7" style="text-transform:uppercase" />
        </div>
        <div class="col-md-2" v-if="opcion == 1">
          <label for="axo">Año</label>
          <input id="axo" v-model="axo" class="form-control" maxlength="4" />
        </div>
        <div class="col-md-2">
          <label for="folio">Folio</label>
          <input id="folio" v-model="folio" class="form-control" maxlength="7" />
        </div>
      </div>
      <div class="mb-3">
        <button class="btn btn-primary me-2" @click="aplicar" :disabled="loading">APLICA</button>
        <button class="btn btn-secondary" @click="limpiar">LIMPIAR</button>
      </div>
      <div v-if="mensaje" :class="{'alert': true, 'alert-success': exito, 'alert-danger': !exito}">
        {{ mensaje }}
      </div>
    </div>
    <div v-if="folioData && folioData.length">
      <h5>Datos del Folio Encontrado</h5>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Control</th>
            <th>Año</th>
            <th>Folio</th>
            <th>Fecha Folio</th>
            <th>Placa</th>
            <th>Infracción</th>
            <th>Estado</th>
            <th>Vigilante</th>
            <th>Num Acuerdo</th>
            <th>Fec Cap</th>
            <th>Usu Inicial</th>
            <th>Zona</th>
            <th>Espacio</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in folioData" :key="row.control">
            <td>{{ row.control }}</td>
            <td>{{ row.axo }}</td>
            <td>{{ row.folio }}</td>
            <td>{{ row.fecha_folio }}</td>
            <td>{{ row.placa }}</td>
            <td>{{ row.infraccion }}</td>
            <td>{{ row.estado }}</td>
            <td>{{ row.vigilante }}</td>
            <td>{{ row.num_acuerdo }}</td>
            <td>{{ row.fec_cap }}</td>
            <td>{{ row.usu_inicial }}</td>
            <td>{{ row.zona }}</td>
            <td>{{ row.espacio }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ReactivaFoliosPage',
  data() {
    return {
      opcion: '0',
      placa: '',
      axo: '',
      folio: '',
      mensaje: '',
      exito: false,
      loading: false,
      folioData: null
    };
  },
  watch: {
    opcion(newVal) {
      this.limpiarCampos();
    }
  },
  methods: {
    limpiarCampos() {
      this.placa = '';
      this.axo = '';
      this.folio = '';
      this.folioData = null;
      this.mensaje = '';
      this.exito = false;
    },
    limpiar() {
      this.limpiarCampos();
    },
    async aplicar() {
      this.mensaje = '';
      this.exito = false;
      this.folioData = null;
      if (this.opcion === '0') {
        if (!this.placa || !this.folio) {
          this.mensaje = 'La Placa y Folio son obligatorios';
          return;
        }
      } else {
        if (!this.axo || !this.folio) {
          this.mensaje = 'El Año y Folio son obligatorios';
          return;
        }
      }
      this.loading = true;
      try {
        // Buscar folio primero
        const buscarResp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'reactiva_folios_buscar',
            params: {
              opcion: parseInt(this.opcion),
              placa: this.placa.trim().toUpperCase(),
              axo: this.axo.trim(),
              folio: this.folio.trim()
            }
          })
        });
        const buscarJson = await buscarResp.json();
        if (!buscarJson.eResponse.success || !buscarJson.eResponse.data.length) {
          this.mensaje = 'No existe registro como adeudo';
          this.exito = false;
          this.loading = false;
          return;
        }
        this.folioData = buscarJson.eResponse.data;
        // Aplicar reactivación
        const aplicarResp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'reactiva_folios_aplicar',
            params: {
              opcion: parseInt(this.opcion),
              placa: this.placa.trim().toUpperCase(),
              axo: this.axo.trim(),
              folio: this.folio.trim()
            }
          })
        });
        const aplicarJson = await aplicarResp.json();
        if (aplicarJson.eResponse.success) {
          this.mensaje = aplicarJson.eResponse.message || 'Se GRABÓ el Adeudo y se ELIMINÓ el Histórico';
          this.exito = true;
          this.limpiarCampos();
        } else {
          this.mensaje = aplicarJson.eResponse.message || 'Error al grabar EN ADEUDO y borrar HISTÓRICO';
          this.exito = false;
        }
      } catch (e) {
        this.mensaje = 'Error de comunicación con el servidor';
        this.exito = false;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.reactiva-folios-page {
  max-width: 800px;
  margin: 0 auto;
}
.breadcrumb {
  background: none;
  padding-left: 0;
}
</style>
