<template>
  <div class="derechos-lic-form">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Descuentos en Derechos de Licencias</li>
      </ol>
    </nav>
    <h1>Descuentos en Derechos de Licencias</h1>
    <form @submit.prevent="buscar">
      <div class="form-group">
        <label for="folio">Licencia/Anuncio</label>
        <input v-model="folio" type="number" class="form-control" id="folio" required />
      </div>
      <div class="form-group">
        <label for="tipo">Tipo</label>
        <select v-model="tipo" class="form-control" id="tipo">
          <option value="L">Licencia</option>
          <option value="A">Anuncio</option>
          <option value="F">Forma</option>
        </select>
      </div>
      <button type="submit" class="btn btn-primary">Buscar</button>
    </form>

    <div v-if="busqueda">
      <h2>Datos de {{ tipoLabel }}</h2>
      <div v-if="busqueda.data && busqueda.data.length">
        <table class="table table-bordered">
          <thead>
            <tr>
              <th>ID</th>
              <th>Licencia/Anuncio</th>
              <th>Propietario</th>
              <th>Min</th>
              <th>Max</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in busqueda.data" :key="item.id_licencia || item.id_anuncio">
              <td>{{ item.id_licencia || item.id_anuncio }}</td>
              <td>{{ item.licencia || item.anuncio }}</td>
              <td>{{ item.propietario }}</td>
              <td>{{ item.min }}</td>
              <td>{{ item.max }}</td>
              <td>
                <button class="btn btn-success btn-sm" @click="abrirDescuento(item)">Descuento</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-else class="alert alert-warning">No se encontraron resultados.</div>
    </div>

    <div v-if="descuentoForm">
      <h2>Alta de Descuento</h2>
      <form @submit.prevent="altaDescuento">
        <div class="form-group">
          <label for="porcentaje">Porcentaje</label>
          <input v-model.number="descuentoForm.porcentaje" type="number" min="1" max="100" class="form-control" id="porcentaje" required />
        </div>
        <div class="form-group">
          <label for="axoini">Año Inicial</label>
          <input v-model.number="descuentoForm.axoini" type="number" class="form-control" id="axoini" required />
        </div>
        <div class="form-group">
          <label for="axofin">Año Final</label>
          <input v-model.number="descuentoForm.axofin" type="number" class="form-control" id="axofin" required />
        </div>
        <div class="form-group">
          <label for="autoriza">Autoriza</label>
          <select v-model.number="descuentoForm.autoriza" class="form-control" id="autoriza">
            <option v-for="aut in funcionarios" :key="aut.cveautoriza" :value="aut.cveautoriza">
              {{ aut.descripcion }} ({{ aut.porcentajetope }}%)
            </option>
          </select>
        </div>
        <button type="submit" class="btn btn-primary">Guardar Descuento</button>
        <button type="button" class="btn btn-secondary ml-2" @click="descuentoForm = null">Cancelar</button>
      </form>
    </div>

    <div v-if="descuentos && descuentos.length">
      <h2>Descuentos Vigentes</h2>
      <table class="table table-striped">
        <thead>
          <tr>
            <th>ID</th>
            <th>Porcentaje</th>
            <th>Año Inicial</th>
            <th>Año Final</th>
            <th>Estado</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="desc in descuentos" :key="desc.id_descto">
            <td>{{ desc.id_descto }}</td>
            <td>{{ desc.porcentaje }}%</td>
            <td>{{ desc.axoini }}</td>
            <td>{{ desc.axofin }}</td>
            <td>{{ desc.estado }}</td>
            <td>
              <button class="btn btn-danger btn-sm" @click="cancelarDescuento(desc)">Cancelar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="reporte">
      <h2>Reporte Estado de Cuenta</h2>
      <pre>{{ JSON.stringify(reporte, null, 2) }}</pre>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'DerechosLicForm',
  data() {
    return {
      folio: '',
      tipo: 'L',
      busqueda: null,
      descuentoForm: null,
      descuentos: [],
      funcionarios: [],
      reporte: null
    };
  },
  computed: {
    tipoLabel() {
      switch (this.tipo) {
        case 'L': return 'Licencia';
        case 'A': return 'Anuncio';
        case 'F': return 'Forma';
        default: return '';
      }
    }
  },
  methods: {
    async buscar() {
      this.busqueda = null;
      this.descuentoForm = null;
      this.descuentos = [];
      this.reporte = null;
      let action = '';
      if (this.tipo === 'L') action = 'buscarLicencia';
      else if (this.tipo === 'A') action = 'buscarAnuncio';
      else if (this.tipo === 'F') action = 'buscarForma';
      const res = await axios.post('/api/execute', {
        action,
        params: { folio: this.folio }
      });
      this.busqueda = res.data;
      if (res.data.data && res.data.data.length) {
        const id = res.data.data[0].id_licencia || res.data.data[0].id_anuncio;
        // Cargar descuentos vigentes
        const descRes = await axios.post('/api/execute', {
          action: 'buscarDescuento',
          params: { tipo: this.tipo, folio: id }
        });
        this.descuentos = descRes.data.data;
        // Cargar funcionarios autorizados
        const funcRes = await axios.post('/api/execute', {
          action: 'buscarCampania',
          params: { fecha: new Date().toISOString().slice(0, 10) }
        });
        this.funcionarios = funcRes.data.data;
      }
    },
    abrirDescuento(item) {
      this.descuentoForm = {
        tipo: this.tipo,
        licencia: item.id_licencia || item.id_anuncio,
        porcentaje: '',
        axoini: item.min,
        axofin: item.max,
        autoriza: this.funcionarios.length ? this.funcionarios[0].cveautoriza : null
      };
    },
    async altaDescuento() {
      if (!this.descuentoForm) return;
      const res = await axios.post('/api/execute', {
        action: 'altaDescuento',
        params: this.descuentoForm
      });
      alert('Descuento registrado correctamente');
      this.descuentoForm = null;
      this.buscar();
    },
    async cancelarDescuento(desc) {
      if (!confirm('¿Está seguro de cancelar este descuento?')) return;
      await axios.post('/api/execute', {
        action: 'cancelarDescuento',
        params: { id_descto: desc.id_descto, licencia: desc.licencia }
      });
      alert('Descuento cancelado');
      this.buscar();
    },
    async generarReporte() {
      const res = await axios.post('/api/execute', {
        action: 'reporteEdoCtaLic',
        params: { tipo: this.tipo, numero: this.folio }
      });
      this.reporte = res.data.data;
    }
  }
};
</script>

<style scoped>
.derechos-lic-form {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.breadcrumb {
  background: transparent;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
