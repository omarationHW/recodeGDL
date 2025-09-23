<template>
  <div class="gadeudos-opcmult-page">
    <h1>{{ pageTitle }}</h1>
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>{{ pageTitle }}</span>
    </nav>
    <div class="search-section">
      <label>{{ busquedaLabel }}</label>
      <div v-if="showNumExpN">
        <input v-model="form.numExpN" @keyup.enter="buscar" maxlength="10" placeholder="Número de Expediente" />
      </div>
      <div v-if="showLocalNum">
        <input v-model="form.localNum" @keyup.enter="focusLetra" maxlength="3" placeholder="Número de Local" />
        <input v-model="form.letra" @keyup.enter="buscar" maxlength="2" placeholder="Letra" />
      </div>
      <button @click="buscar">Buscar</button>
    </div>
    <div v-if="concesion" class="concesion-info">
      <h2>Datos del Concesionario</h2>
      <ul>
        <li><strong>Status:</strong> {{ concesion.statusregistro }}</li>
        <li><strong>Concesionario:</strong> {{ concesion.concesionario }}</li>
        <li><strong>Ubicación:</strong> {{ concesion.ubicacion }}</li>
        <li><strong>Nombre Comercial:</strong> {{ concesion.nomcomercial }}</li>
        <li><strong>Lugar:</strong> {{ concesion.lugar }}</li>
        <li><strong>Observaciones:</strong> {{ concesion.obs }}</li>
        <li><strong>Tipo:</strong> {{ concesion.unidades }}</li>
        <li><strong>Inicio Obligación:</strong> {{ concesion.fechainicio }}</li>
        <li><strong>Fin Obligación:</strong> {{ concesion.fechafin }}</li>
        <li><strong>Superficie:</strong> {{ concesion.superficie }}</li>
        <li><strong>Recaudadora:</strong> {{ concesion.recaudadora }}</li>
        <li><strong>Sector:</strong> {{ concesion.sector }}</li>
        <li><strong>Zona:</strong> {{ concesion.zona }}</li>
        <li><strong>Licencia:</strong> {{ concesion.licencia }}</li>
      </ul>
    </div>
    <div v-if="adeudos.length > 0" class="adeudos-section">
      <h2>Adeudos</h2>
      <table class="adeudos-table">
        <thead>
          <tr>
            <th>Concepto</th>
            <th>Adeudo</th>
            <th>Recargo</th>
            <th>Multa</th>
            <th>Actualización</th>
            <th>Dcto. Adeudo</th>
            <th>Dcto. Rcgo.</th>
            <th>Dcto. Multa</th>
            <th>Seleccionar</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in adeudos" :key="idx">
            <td>{{ row.concepto }}</td>
            <td>{{ row.importe_pagar }}</td>
            <td>{{ row.recargos_pagar }}</td>
            <td>{{ row.multa_pagar }}</td>
            <td>{{ row.actualizacion_pagar }}</td>
            <td>{{ row.dscto_importe }}</td>
            <td>{{ row.dscto_recargos }}</td>
            <td>{{ row.dscto_multa }}</td>
            <td><input type="checkbox" v-model="row.selected" /></td>
          </tr>
        </tbody>
      </table>
      <div class="opciones-section">
        <label>Fecha de Pago:</label>
        <input type="date" v-model="form.fechaPagado" />
        <label>Recaudadora:</label>
        <select v-model="form.recaudadora">
          <option v-for="r in recaudadoras" :key="r.id_rec" :value="r.id_rec">{{ r.id_rec }} - {{ r.recaudadora }}</option>
        </select>
        <label>Caja:</label>
        <input v-model="form.caja" maxlength="2" />
        <label>Consec. Oper.:</label>
        <input v-model="form.consecOper" maxlength="7" />
        <label>Folio Recibo:</label>
        <input v-model="form.folioRcbo" maxlength="15" />
        <label>Opción:</label>
        <select v-model="form.opcion">
          <option v-for="op in opciones" :key="op.value" :value="op.value">{{ op.label }}</option>
        </select>
        <button @click="ejecutarOpcion">Ejecutar</button>
      </div>
      <div v-if="pagados.length > 0" class="pagados-section">
        <h3>Pagados</h3>
        <table>
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
            <tr v-for="(p, idx) in pagados" :key="idx">
              <td>{{ p.periodo }}</td>
              <td>{{ p.importe }}</td>
              <td>{{ p.recargo }}</td>
              <td>{{ p.fecha_hora_pago }}</td>
              <td>{{ p.id_recaudadora }}</td>
              <td>{{ p.caja }}</td>
              <td>{{ p.operacion }}</td>
              <td>{{ p.folio_recibo }}</td>
              <td>{{ p.usuario }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="error" class="error-message">{{ error }}</div>
    <div v-if="success" class="success-message">{{ success }}</div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'GAdeudosOpcMultPage',
  data() {
    return {
      pageTitle: 'Opción Múltiple de Adeudos',
      busquedaLabel: 'Búsqueda por:',
      form: {
        numExpN: '',
        localNum: '',
        letra: '',
        fechaPagado: new Date().toISOString().substr(0, 10),
        recaudadora: '',
        caja: '',
        consecOper: '',
        folioRcbo: '',
        opcion: ''
      },
      showNumExpN: true,
      showLocalNum: false,
      concesion: null,
      adeudos: [],
      recaudadoras: [],
      opciones: [],
      pagados: [],
      error: '',
      success: '',
      glo_Tabla: 3, // Por defecto, puede venir de ruta o props
      glo_Opc: 1 // 1=Pagado, 2=Condonar, 3=Cancelar, 4=Prescribir
    };
  },
  created() {
    this.initPage();
  },
  methods: {
    async initPage() {
      // Cargar recaudadoras
      try {
        let rec = await axios.post('/api/execute', { action: 'getRecaudadoras' });
        this.recaudadoras = rec.data.data;
        if (this.recaudadoras.length > 0) this.form.recaudadora = this.recaudadoras[0].id_rec;
      } catch (e) {
        this.error = 'Error cargando recaudadoras';
      }
      // Opciones según glo_Opc
      switch (this.glo_Opc) {
        case 1:
          this.opciones = [{ value: 'P', label: 'P - DAR DE PAGADO' }];
          this.pageTitle = 'Dar de Pagado Adeudos';
          break;
        case 2:
          this.opciones = [{ value: 'S', label: 'S - CONDONAR' }];
          this.pageTitle = 'Condonar Adeudos';
          break;
        case 3:
          this.opciones = [{ value: 'C', label: 'C - CANCELAR' }];
          this.pageTitle = 'Cancelar Adeudos';
          break;
        case 4:
          this.opciones = [{ value: 'R', label: 'R - PRESCRIBIR' }];
          this.pageTitle = 'Prescribir Adeudos';
          break;
      }
      // Mostrar campos según tabla
      if ([1, 2, 4, 5].includes(this.glo_Tabla)) {
        this.showNumExpN = true;
        this.showLocalNum = false;
      } else if (this.glo_Tabla === 3) {
        this.showNumExpN = false;
        this.showLocalNum = true;
      }
    },
    focusLetra() {
      this.$refs.letra && this.$refs.letra.focus();
    },
    async buscar() {
      this.error = '';
      this.success = '';
      let par_control = '';
      if (this.showNumExpN) {
        if (!this.form.numExpN) {
          this.error = 'Falta el dato del Número de Expediente';
          return;
        }
        // Obtener abreviatura
        let etiq = await axios.post('/api/execute', { action: 'getEtiquetas', params: { par_tab: this.glo_Tabla } });
        let abrev = etiq.data.data[0]?.abreviatura || '';
        par_control = abrev + this.form.numExpN;
      } else {
        if (!this.form.localNum) {
          this.error = 'Falta el dato del Número de Local';
          return;
        }
        par_control = this.form.localNum + (this.form.letra ? '-' + this.form.letra : '');
      }
      // Buscar concesión
      let resp = await axios.post('/api/execute', { action: 'getConcesionDatos', params: { par_tab: this.glo_Tabla, par_control } });
      if (!resp.data.data || resp.data.data.length === 0 || resp.data.data[0].status === -1) {
        this.error = 'No existe registro alguno con este dato';
        this.concesion = null;
        this.adeudos = [];
        return;
      }
      this.concesion = resp.data.data[0];
      // Buscar adeudos
      let year = new Date().getFullYear();
      let params = {
        par_tabla: this.glo_Tabla,
        par_id_datos: this.concesion.id_datos,
        par_aso: year,
        par_mes: 12
      };
      let adeudosResp = await axios.post('/api/execute', { action: 'getAdeudosDetalle', params });
      this.adeudos = (adeudosResp.data.data || []).map(row => ({ ...row, selected: false }));
      // Buscar pagados
      let pagadosResp = await axios.post('/api/execute', { action: 'getPagados', params: { p_Control: this.concesion.id_datos } });
      this.pagados = pagadosResp.data.data || [];
    },
    async ejecutarOpcion() {
      this.error = '';
      this.success = '';
      let selectedRows = this.adeudos.filter(r => r.selected);
      if (selectedRows.length === 0) {
        this.error = 'Debe seleccionar al menos un adeudo.';
        return;
      }
      for (let row of selectedRows) {
        let params = {
          par_id_34_datos: this.concesion.id_datos,
          par_Axo: row.axo,
          par_Mes: row.mes,
          par_Fecha: this.form.fechaPagado,
          par_Id_Rec: this.form.recaudadora,
          par_Caja: this.form.caja,
          par_Consec: this.form.consecOper,
          par_Folio_rcbo: this.form.folioRcbo,
          par_tab: 'E',
          par_status: this.form.opcion,
          par_Opc: 'B',
          par_usuario: 'usuario_actual' // Reemplazar por usuario real
        };
        let resp = await axios.post('/api/execute', { action: 'procesarOpcionMultiple', params });
        if (resp.data.success && resp.data.data && resp.data.data[0].status === 1) {
          this.success = resp.data.data[0].concepto_status;
        } else {
          this.error = resp.data.data[0]?.concepto_status || 'Error al procesar.';
        }
      }
      // Refrescar adeudos
      await this.buscar();
    }
  }
};
</script>

<style scoped>
.gadeudos-opcmult-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.search-section {
  margin-bottom: 2rem;
}
.adeudos-table {
  width: 100%;
  border-collapse: collapse;
}
.adeudos-table th, .adeudos-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.opciones-section {
  margin-top: 1rem;
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: center;
}
.error-message {
  color: red;
  margin-top: 1rem;
}
.success-message {
  color: green;
  margin-top: 1rem;
}
</style>
