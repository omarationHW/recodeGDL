<template>
  <div class="gconsulta2-page">
    <div class="breadcrumbs">
      <span>Inicio</span> &gt; <span>Consultas</span> &gt; <span>Consulta General</span>
    </div>
    <h1>Consulta General</h1>
    <div class="panel panel-top">
      <div class="form-row">
        <label>Tabla:</label>
        <span>{{ nombreTabla }}</span>
      </div>
      <div class="form-row">
        <label>Buscar por:</label>
        <select v-model="tipoBusqueda" @change="onTipoBusquedaChange">
          <option v-for="(item, idx) in opcionesBusqueda" :key="idx" :value="item.value">{{ item.label }}</option>
        </select>
        <input v-model="datoBusqueda" @keyup.enter="buscarCoincide" placeholder="Ingrese dato a buscar..." />
        <button @click="buscarCoincide">Buscar</button>
      </div>
      <div class="form-row">
        <label>Resultados:</label>
        <select v-model="controlSeleccionado" @change="onControlSeleccionado">
          <option v-for="(item, idx) in listaCoincide" :key="idx" :value="item.control">{{ item.control }}</option>
        </select>
      </div>
      <div class="form-row datos-principales">
        <div><strong>{{ etiquetas.concesionario }}:</strong> {{ datos.concesionario }}</div>
        <div><strong>{{ etiquetas.ubicacion }}:</strong> {{ datos.ubicacion }}</div>
        <div><strong>{{ etiquetas.nomcomercial }}:</strong> {{ datos.nomcomercial }}</div>
        <div><strong>{{ etiquetas.lugar }}:</strong> {{ datos.lugar }}</div>
        <div><strong>{{ etiquetas.obs }}:</strong> {{ datos.obs }}</div>
        <div><strong>{{ etiquetas.statusregistro }}:</strong> {{ datos.statusregistro }}</div>
        <div><strong>{{ etiquetas.recaudadora }}:</strong> {{ datos.recaudadora }}</div>
        <div><strong>{{ etiquetas.sector }}:</strong> {{ datos.sector }}</div>
        <div><strong>{{ etiquetas.zona }}:</strong> {{ datos.zona }}</div>
        <div><strong>{{ etiquetas.fechainicio }}:</strong> {{ datos.fechainicio }}</div>
        <div><strong>{{ etiquetas.superficie }}:</strong> {{ datos.superficie }}</div>
        <div><strong>{{ etiquetas.licencia }}:</strong> {{ datos.licencia }}</div>
        <div><strong>{{ etiquetas.unidades }}:</strong> {{ datos.unidades }}</div>
      </div>
      <div class="form-row">
        <button v-if="pagados.length > 0" @click="mostrarPagados = !mostrarPagados">Ver Pagados</button>
        <button v-if="tieneApremios" @click="mostrarApremios = !mostrarApremios">Ver Apremios</button>
      </div>
    </div>
    <div class="panel panel-adeudos" v-if="datos.id_datos">
      <h2>Adeudos Detalle</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Concepto</th>
            <th>Renta</th>
            <th>Rcgo. Renta</th>
            <th>Dcto. Renta</th>
            <th>Dcto. Rcgos.</th>
            <th>Actualización</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in adeudos" :key="idx">
            <td>{{ row.concepto }}</td>
            <td>{{ row.importe_pagar | currency }}</td>
            <td>{{ row.recargos_pagar | currency }}</td>
            <td>{{ row.dscto_importe | currency }}</td>
            <td>{{ row.dscto_recargos | currency }}</td>
            <td>{{ row.actualizacion_pagar | currency }}</td>
          </tr>
        </tbody>
      </table>
      <h2>Totales</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Cuenta</th>
            <th>Concepto</th>
            <th>Importe</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in totales" :key="idx">
            <td>{{ row.cuenta }}</td>
            <td>{{ row.concepto }}</td>
            <td>{{ row.importe | currency }}</td>
          </tr>
        </tbody>
      </table>
      <div class="total-pagar">
        <strong>Total a Pagar:</strong> {{ totalPagar | currency }}
      </div>
    </div>
    <div v-if="mostrarPagados">
      <h2>Pagos Realizados</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Periodo</th>
            <th>Importe</th>
            <th>Recargo</th>
            <th>Fecha Pago</th>
            <th>Recaudadora</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Folio Recibo</th>
            <th>Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in pagados" :key="idx">
            <td>{{ row.periodo }}</td>
            <td>{{ row.importe | currency }}</td>
            <td>{{ row.recargo | currency }}</td>
            <td>{{ row.fecha_hora_pago }}</td>
            <td>{{ row.id_recaudadora }}</td>
            <td>{{ row.caja }}</td>
            <td>{{ row.operacion }}</td>
            <td>{{ row.folio_recibo }}</td>
            <td>{{ row.usuario }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="mostrarApremios">
      <h2>Apremios</h2>
      <div>Funcionalidad pendiente de implementar (requiere endpoint específico)</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'GConsulta2',
  data() {
    return {
      nombreTabla: '',
      etiquetas: {},
      tipoBusqueda: '1',
      opcionesBusqueda: [
        { value: '1', label: 'CONTROL' },
        { value: '2', label: 'CONCESIONARIO' },
        { value: '3', label: 'UBICACION' },
        { value: '4', label: 'NOMBRE COMERCIAL' },
        { value: '5', label: 'LUGAR' },
        { value: '6', label: 'OBSERVACIONES' }
      ],
      datoBusqueda: '',
      listaCoincide: [],
      controlSeleccionado: '',
      datos: {},
      adeudos: [],
      totales: [],
      totalPagar: 0,
      pagados: [],
      mostrarPagados: false,
      mostrarApremios: false,
      tieneApremios: false,
      glo_Opc: 1 // Por defecto, puede venir por props o ruta
    };
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  },
  mounted() {
    this.cargarEtiquetas();
    this.cargarTabla();
  },
  methods: {
    async cargarEtiquetas() {
      const res = await this.$axios.post('/api/execute', {
        action: 'gconsulta2.getEtiquetas',
        params: { par_tab: this.glo_Opc }
      });
      if (res.data.success && res.data.data.length > 0) {
        this.etiquetas = res.data.data[0];
      }
    },
    async cargarTabla() {
      const res = await this.$axios.post('/api/execute', {
        action: 'gconsulta2.getTablas',
        params: { par_tab: this.glo_Opc }
      });
      if (res.data.success && res.data.data.length > 0) {
        this.nombreTabla = res.data.data[0].nombre;
      }
    },
    async buscarCoincide() {
      this.listaCoincide = [];
      this.datos = {};
      this.adeudos = [];
      this.totales = [];
      this.totalPagar = 0;
      this.pagados = [];
      this.mostrarPagados = false;
      this.mostrarApremios = false;
      const res = await this.$axios.post('/api/execute', {
        action: 'gconsulta2.buscarCoincide',
        params: {
          par_tab: this.glo_Opc,
          tipo_busqueda: this.tipoBusqueda,
          dato_busqueda: this.datoBusqueda
        }
      });
      if (res.data.success) {
        this.listaCoincide = res.data.data;
        if (this.listaCoincide.length > 0) {
          this.controlSeleccionado = this.listaCoincide[0].control;
          this.onControlSeleccionado();
        }
      }
    },
    async onControlSeleccionado() {
      if (!this.controlSeleccionado) return;
      // Buscar datos principales
      const res = await this.$axios.post('/api/execute', {
        action: 'gconsulta2.buscarCont',
        params: {
          par_tab: this.glo_Opc,
          par_control: this.controlSeleccionado
        }
      });
      if (res.data.success && res.data.data.length > 0) {
        this.datos = res.data.data[0];
        // Buscar adeudos y totales
        await this.buscarAdeudos();
        await this.buscarTotales();
        await this.buscarPagados();
      }
    },
    async buscarAdeudos() {
      const fecha = new Date();
      const par_aso = fecha.getFullYear();
      const par_mes = 12;
      const res = await this.$axios.post('/api/execute', {
        action: 'gconsulta2.buscarAdeudos',
        params: {
          par_tabla: this.glo_Opc,
          par_id_datos: this.datos.id_datos,
          par_aso,
          par_mes
        }
      });
      if (res.data.success) {
        this.adeudos = res.data.data;
      }
    },
    async buscarTotales() {
      const fecha = new Date();
      const par_aso = fecha.getFullYear();
      const par_mes = 12;
      const res = await this.$axios.post('/api/execute', {
        action: 'gconsulta2.buscarTotales',
        params: {
          par_tabla: this.glo_Opc,
          par_id_datos: this.datos.id_datos,
          par_aso,
          par_mes
        }
      });
      if (res.data.success) {
        this.totales = res.data.data;
        let total = 0;
        this.tieneApremios = false;
        for (const row of this.totales) {
          if (row.concepto && (row.concepto.trim() === 'Gastos' || row.concepto.trim() === 'Multas')) {
            this.tieneApremios = true;
          }
          total += Number(row.importe);
        }
        this.totalPagar = total;
      }
    },
    async buscarPagados() {
      const res = await this.$axios.post('/api/execute', {
        action: 'gconsulta2.buscarPagados',
        params: {
          p_Control: this.datos.id_datos
        }
      });
      if (res.data.success) {
        this.pagados = res.data.data;
      }
    },
    onTipoBusquedaChange() {
      this.datoBusqueda = '';
      this.listaCoincide = [];
      this.datos = {};
      this.adeudos = [];
      this.totales = [];
      this.totalPagar = 0;
      this.pagados = [];
      this.mostrarPagados = false;
      this.mostrarApremios = false;
    }
  }
};
</script>

<style scoped>
.gconsulta2-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.panel {
  background: #f9f9f9;
  border: 1px solid #ddd;
  margin-bottom: 2rem;
  padding: 1rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 150px;
  font-weight: bold;
}
.form-row input, .form-row select {
  margin-right: 1rem;
}
.datos-principales {
  flex-wrap: wrap;
  gap: 1rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.total-pagar {
  margin-top: 1rem;
  font-size: 1.2em;
  font-weight: bold;
}
.breadcrumbs {
  font-size: 0.9em;
  color: #888;
  margin-bottom: 1rem;
}
</style>
