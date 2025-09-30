<template>
  <div class="responsiva-page">
    <h1>Emisión de Responsivas</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Responsivas
    </div>
    <div class="search-section">
      <label>Buscar Licencia:</label>
      <input v-model="licenciaBusqueda" @keyup.enter="buscarLicencia" placeholder="Número de licencia" />
      <button @click="buscarLicencia">Buscar</button>
    </div>
    <div v-if="licenciaEncontrada">
      <h3>Datos de Licencia</h3>
      <ul>
        <li><b>Licencia:</b> {{ licenciaEncontrada.licencia }}</li>
        <li><b>Recaudadora:</b> {{ licenciaEncontrada.recaud }}</li>
        <li><b>Giro:</b> {{ licenciaEncontrada.descripcion }}</li>
        <li><b>Actividad:</b> {{ licenciaEncontrada.actividad }}</li>
        <li><b>Propietario:</b> {{ licenciaEncontrada.propietarionvo }}</li>
        <li><b>Ubicación:</b> {{ licenciaEncontrada.ubicacion }}</li>
        <li><b>No. ext:</b> {{ licenciaEncontrada.numext_ubic }} <b>Letra ext:</b> {{ licenciaEncontrada.letraext_ubic }}</li>
        <li><b>No. int:</b> {{ licenciaEncontrada.numint_ubic }} <b>Letra int:</b> {{ licenciaEncontrada.letraint_ubic }}</li>
        <li><b>Colonia:</b> {{ licenciaEncontrada.colonia_ubic }}</li>
        <li><b>CP:</b> {{ licenciaEncontrada.cp }}</li>
      </ul>
    </div>
    <div class="actions" v-if="licenciaEncontrada">
      <button @click="nuevaResponsiva('R')">Nueva Responsiva</button>
      <button @click="nuevaResponsiva('S')">Nueva Supervisión</button>
    </div>
    <div class="filter-section">
      <label>Año:</label>
      <input v-model.number="filtroAxo" type="number" style="width:80px" />
      <label>Folio:</label>
      <input v-model.number="filtroFolio" type="number" style="width:80px" />
      <label>Licencia:</label>
      <input v-model="filtroLicencia" style="width:100px" />
      <button @click="buscarPorFiltros">Buscar</button>
      <label>Tipo:</label>
      <select v-model="tipoSeleccionado">
        <option value="R">Responsiva</option>
        <option value="S">Supervisión</option>
      </select>
    </div>
    <div class="table-section">
      <h3>Responsivas</h3>
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Año</th>
            <th>Folio</th>
            <th>Licencia</th>
            <th>Tipo</th>
            <th>Observación</th>
            <th>Vigente</th>
            <th>Fecha Captura</th>
            <th>Capturista</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="resp in responsivas" :key="resp.axo+'-'+resp.folio">
            <td>{{ resp.axo }}</td>
            <td>{{ resp.folio }}</td>
            <td>{{ resp.licencia }}</td>
            <td>{{ resp.tipo }}</td>
            <td>{{ resp.observacion }}</td>
            <td>{{ resp.vigente }}</td>
            <td>{{ resp.feccap }}</td>
            <td>{{ resp.capturista }}</td>
            <td>
              <button @click="imprimir(resp)" :disabled="resp.vigente==='C'">Imprimir</button>
              <button @click="cancelar(resp)" :disabled="resp.vigente==='C'">Cancelar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="showDialog">
      <div class="modal">
        <h3>Cancelar Responsiva</h3>
        <p>¿Está seguro de cancelar la responsiva {{ dialogData.axo }}/{{ dialogData.folio }}?</p>
        <input v-model="motivoCancelacion" placeholder="Motivo de cancelación" />
        <button @click="confirmarCancelacion">Confirmar</button>
        <button @click="showDialog=false">Cerrar</button>
      </div>
    </div>
    <div v-if="mensaje" class="alert alert-info">{{ mensaje }}</div>
  </div>
</template>

<script>
export default {
  name: 'ResponsivaPage',
  data() {
    return {
      licenciaBusqueda: '',
      licenciaEncontrada: null,
      responsivas: [],
      filtroAxo: '',
      filtroFolio: '',
      filtroLicencia: '',
      tipoSeleccionado: 'R',
      showDialog: false,
      dialogData: {},
      motivoCancelacion: '',
      mensaje: ''
    }
  },
  created() {
    this.cargarResponsivas();
  },
  methods: {
    async buscarLicencia() {
      this.mensaje = '';
      if (!this.licenciaBusqueda) return;
      const res = await this.api('buscarLicencia', {licencia: this.licenciaBusqueda});
      if (res.success && res.data && res.data.length) {
        this.licenciaEncontrada = res.data[0];
      } else {
        this.licenciaEncontrada = null;
        this.mensaje = 'No se encontró licencia con ese número.';
      }
    },
    async cargarResponsivas() {
      const res = await this.api('listarResponsivas', {tipo: this.tipoSeleccionado});
      if (res.success) {
        this.responsivas = res.data;
      }
    },
    async nuevaResponsiva(tipo) {
      if (!this.licenciaEncontrada) return;
      const usuario = this.getUsuario();
      const payload = {
        id_licencia: this.licenciaEncontrada.id_licencia,
        tipo,
        usuario
      };
      const res = await this.api('crearResponsiva', payload);
      if (res.success) {
        this.mensaje = 'Responsiva creada correctamente';
        this.cargarResponsivas();
      } else {
        this.mensaje = res.message || 'Error al crear responsiva';
      }
    },
    async cancelar(resp) {
      this.showDialog = true;
      this.dialogData = resp;
      this.motivoCancelacion = '';
    },
    async confirmarCancelacion() {
      if (!this.motivoCancelacion) {
        this.mensaje = 'Debe indicar el motivo de cancelación';
        return;
      }
      const usuario = this.getUsuario();
      const res = await this.api('cancelarResponsiva', {
        axo: this.dialogData.axo,
        folio: this.dialogData.folio,
        motivo: this.motivoCancelacion,
        usuario
      });
      if (res.success) {
        this.mensaje = 'Responsiva cancelada correctamente';
        this.cargarResponsivas();
      } else {
        this.mensaje = res.message || 'Error al cancelar responsiva';
      }
      this.showDialog = false;
    },
    async buscarPorFiltros() {
      this.mensaje = '';
      if (this.filtroAxo && this.filtroFolio) {
        const res = await this.api('buscarPorFolio', {
          axo: this.filtroAxo,
          folio: this.filtroFolio,
          tipo: this.tipoSeleccionado
        });
        if (res.success) this.responsivas = res.data;
      } else if (this.filtroLicencia) {
        const res = await this.api('buscarPorLicencia', {
          licencia: this.filtroLicencia,
          tipo: this.tipoSeleccionado
        });
        if (res.success) this.responsivas = res.data;
      } else {
        this.cargarResponsivas();
      }
    },
    imprimir(resp) {
      // Aquí se debe integrar la impresión PDF (por ejemplo, abrir un reporte generado por backend)
      alert('Funcionalidad de impresión no implementada en este demo.');
    },
    getUsuario() {
      // Obtener usuario autenticado (ajustar según autenticación real)
      return localStorage.getItem('usuario') || 'demo';
    },
    async api(action, payload) {
      try {
        const eRequest = {
          action: `licencias2.${action}`,
          payload: payload
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();
        return data.status === 'success' ?
          { success: true, data: data.eResponse.data.result, message: data.message } :
          { success: false, message: data.message };
      } catch (error) {
        return {success: false, message: error.message};
      }
    }
  }
}
</script>

<style scoped>
.responsiva-page { max-width: 900px; margin: 0 auto; padding: 2rem; }
.breadcrumb { margin-bottom: 1rem; }
.search-section, .filter-section { margin-bottom: 1rem; }
.table-section { margin-top: 2rem; }
.alert { margin-top: 1rem; }
.modal { background: #fff; border: 1px solid #ccc; padding: 2rem; position: fixed; top: 30%; left: 30%; z-index: 1000; }
</style>
