<template>
  <div class="datos-requerimientos-page">
    <div v-if="initialLoading" class="global-loading-overlay">
      <div class="spinner"></div>
      <p>Cargando...</p>
    </div>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de Requerimientos</li>
      </ol>
    </nav>
    <h2>Consulta Individual de Requerimientos por Folio</h2>
    <form @submit.prevent="buscarRequerimiento">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="id_local">ID Local</label>
          <input v-model="form.id_local" type="number" class="form-control" id="id_local" required />
        </div>
        <div class="form-group col-md-2">
          <label for="modulo">Módulo</label>
          <input v-model="form.modulo" type="number" class="form-control" id="modulo" required />
        </div>
        <div class="form-group col-md-2">
          <label for="folio">Folio</label>
          <input v-model="form.folio" type="number" class="form-control" id="folio" required />
        </div>
      </div>
      <button type="submit" class="btn btn-primary">Buscar</button>
    </form>

    <div v-if="loading" class="mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>

    <div v-if="local && mercado" class="mt-4">
      <h4>Datos del Local</h4>
      <table class="table table-sm table-bordered">
        <tr><th>ID</th><td>{{ local.id_local }}</td></tr>
        <tr><th>Oficina</th><td>{{ local.oficina }}</td></tr>
        <tr><th>Num. Mercado</th><td>{{ local.num_mercado }}</td></tr>
        <tr><th>Categoria</th><td>{{ local.categoria }}</td></tr>
        <tr><th>Sección</th><td>{{ local.seccion }}</td></tr>
        <tr><th>Letra Local</th><td>{{ local.letra_local }}</td></tr>
        <tr><th>Bloque</th><td>{{ local.bloque }}</td></tr>
        <tr><th>Nombre</th><td>{{ local.nombre }}</td></tr>
        <tr><th>Descripción</th><td>{{ local.descripcion_local }}</td></tr>
      </table>
      <h4>Datos del Mercado</h4>
      <table class="table table-sm table-bordered">
        <tr><th>Descripción</th><td>{{ mercado.descripcion }}</td></tr>
        <tr><th>Cuenta Ingreso</th><td>{{ mercado.cuenta_ingreso }}</td></tr>
        <tr><th>Cuenta Energía</th><td>{{ mercado.cuenta_energia }}</td></tr>
      </table>
    </div>

    <div v-if="requerimiento" class="mt-4">
      <h4>Datos del Requerimiento</h4>
      <table class="table table-sm table-bordered">
        <tr><th>Folio</th><td>{{ requerimiento.folio }}</td></tr>
        <tr><th>Diligencia</th><td>{{ requerimiento.diligencia }}</td></tr>
        <tr><th>Importe Global</th><td>{{ requerimiento.importe_global | currency }}</td></tr>
        <tr><th>Importe Multa</th><td>{{ requerimiento.importe_multa | currency }}</td></tr>
        <tr><th>Importe Recargo</th><td>{{ requerimiento.importe_recargo | currency }}</td></tr>
        <tr><th>Importe Gastos</th><td>{{ requerimiento.importe_gastos | currency }}</td></tr>
        <tr><th>Fecha Emisión</th><td>{{ requerimiento.fecha_emision }}</td></tr>
        <tr><th>Clave Practicado</th><td>{{ requerimiento.clave_practicado }}</td></tr>
        <tr><th>Vigencia</th><td>{{ requerimiento.vigencia }}</td></tr>
        <tr><th>Usuario</th><td>{{ requerimiento.usuario_1 }} ({{ requerimiento.nombre }})</td></tr>
        <tr><th>Estado</th><td>{{ requerimiento.estado }}</td></tr>
        <tr><th>Zona</th><td>{{ requerimiento.zona }}</td></tr>
        <tr><th>Zona Apremio</th><td>{{ requerimiento.zona_apremio }}</td></tr>
        <tr><th>Fecha Practicado</th><td>{{ requerimiento.fecha_practicado }}</td></tr>
        <tr><th>Observaciones</th><td>{{ requerimiento.observaciones }}</td></tr>
      </table>
    </div>

    <div v-if="periodos && periodos.length" class="mt-4">
      <h4>Periodos Requeridos</h4>
      <table class="table table-sm table-bordered">
        <thead>
          <tr><th>Año</th><th>Periodo</th><th>Importe</th><th>Recargos</th></tr>
        </thead>
        <tbody>
          <tr v-for="p in periodos" :key="p.id_control">
            <td>{{ p.ayo }}</td>
            <td>{{ p.periodo }}</td>
            <td>{{ p.importe | currency }}</td>
            <td>{{ p.recargos | currency }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DatosRequerimientosPage',
  data() {
    return {
      initialLoading: false,
      form: {
        id_local: '',
        modulo: '',
        folio: ''
      },
      loading: false,
      error: '',
      local: null,
      mercado: null,
      requerimiento: null,
      periodos: []
    }
  },
  methods: {
    async buscarRequerimiento() {
      this.loading = true;
      this.error = '';
      this.local = null;
      this.mercado = null;
      this.requerimiento = null;
      this.periodos = [];
      try {
        // 1. Obtener local
        let res = await this.$axios.post('/api/execute', {
          action: 'getLocales',
          params: { id_local: this.form.id_local }
        });
        if (!res.data.success || !res.data.data.length) throw new Error('Local no encontrado');
        this.local = res.data.data[0];
        // 2. Obtener mercado
        res = await this.$axios.post('/api/execute', {
          action: 'getMercado',
          params: { oficina: this.local.oficina, num_mercado: this.local.num_mercado }
        });
        if (!res.data.success || !res.data.data.length) throw new Error('Mercado no encontrado');
        this.mercado = res.data.data[0];
        // 3. Obtener requerimiento
        res = await this.$axios.post('/api/execute', {
          action: 'getRequerimientos',
          params: {
            modulo: this.form.modulo,
            folio: this.form.folio,
            control_otr: this.form.id_local
          }
        });
        if (!res.data.success || !res.data.data.length) throw new Error('Requerimiento no encontrado');
        this.requerimiento = res.data.data[0];
        // 4. Obtener periodos
        res = await this.$axios.post('/api/execute', {
          action: 'getPeriodos',
          params: { control_otr: this.form.id_local }
        });
        this.periodos = res.data.success ? res.data.data : [];
      } catch (e) {
        this.error = e.message || 'Error al consultar datos';
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
}
</script>

<style scoped>
.datos-requerimientos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
  position: relative;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>
