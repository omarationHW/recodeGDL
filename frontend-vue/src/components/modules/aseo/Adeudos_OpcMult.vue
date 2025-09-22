<template>
  <div class="adeudos-opc-mult">
    <h1>Opción Múltiple de Adeudos</h1>
    <form @submit.prevent="buscarContrato">
      <div class="form-row">
        <label>Contrato:</label>
        <input v-model="form.num_contrato" type="number" required />
      </div>
      <div class="form-row">
        <label>Tipo de Aseo:</label>
        <select v-model="form.ctrol_aseo" required>
          <option v-for="ta in tipoAseo" :key="ta.ctrol_aseo" :value="ta.ctrol_aseo">
            {{ ta.ctrol_aseo }} - {{ ta.tipo_aseo }} - {{ ta.descripcion }}
          </option>
        </select>
      </div>
      <button type="submit">Buscar</button>
    </form>

    <div v-if="contrato">
      <h2>Datos del Contrato</h2>
      <ul>
        <li><b>Empresa:</b> {{ contrato.nom_emp }}</li>
        <li><b>Representante:</b> {{ contrato.representante }}</li>
        <li><b>Domicilio:</b> {{ contrato.domicilio }}</li>
        <li><b>Status Vigencia:</b> {{ contrato.status_vigencia }}</li>
      </ul>
      <div v-if="convenio">
        <b>Convenio:</b> {{ convenio.convenio }}
      </div>
    </div>

    <div v-if="adeudos.length">
      <h2>Adeudos</h2>
      <table class="table">
        <thead>
          <tr>
            <th>Seleccionar</th>
            <th>Periodo</th>
            <th>Descripción</th>
            <th>Cantidad</th>
            <th>Importe</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in adeudos" :key="idx">
            <td><input type="checkbox" v-model="row.selected" /></td>
            <td>{{ row.expression_1 }}</td>
            <td>{{ row.expression_2 }}</td>
            <td>{{ row.expression_4 }}</td>
            <td>{{ row.expression_5 }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="adeudos.length">
      <h2>Ejecutar Opción</h2>
      <form @submit.prevent="ejecutarOpcion">
        <div class="form-row">
          <label>Opción:</label>
          <select v-model="form.opcion" required>
            <option value="P">P - DAR DE PAGADO</option>
            <option value="S">S - CONDONAR</option>
            <option value="C">C - CANCELAR</option>
            <option value="R">R - PRESCRIBIR</option>
          </select>
        </div>
        <div class="form-row">
          <label>Fecha de Pago:</label>
          <input type="date" v-model="form.fecha" required />
        </div>
        <div class="form-row">
          <label>Recaudadora:</label>
          <select v-model="form.reca" required>
            <option v-for="r in recaudadoras" :key="r.id_rec" :value="r.id_rec">
              {{ r.id_rec }} - {{ r.recaudadora }}
            </option>
          </select>
        </div>
        <div class="form-row">
          <label>Caja:</label>
          <input v-model="form.caja" maxlength="2" />
        </div>
        <div class="form-row">
          <label>Consec. Operación:</label>
          <input v-model="form.operacion" type="number" :disabled="form.opcion !== 'P'" />
        </div>
        <div class="form-row">
          <label>Folio Recibo:</label>
          <input v-model="form.folio_rcbo" maxlength="30" />
        </div>
        <div class="form-row">
          <label>Observaciones:</label>
          <textarea v-model="form.obs" maxlength="250"></textarea>
        </div>
        <button type="submit">Ejecutar</button>
      </form>
    </div>
    <div v-if="resultados.length">
      <h3>Resultados:</h3>
      <ul>
        <li v-for="(res, idx) in resultados" :key="idx">{{ res }}</li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosOpcMult',
  data() {
    return {
      tipoAseo: [],
      recaudadoras: [],
      contrato: null,
      convenio: null,
      adeudos: [],
      resultados: [],
      form: {
        num_contrato: '',
        ctrol_aseo: '',
        opcion: 'P',
        fecha: '',
        reca: '',
        caja: '',
        operacion: '',
        folio_rcbo: '',
        obs: '',
        usuario: 1 // Simulación, debe venir de sesión
      }
    };
  },
  mounted() {
    this.cargarTipoAseo();
    this.cargarRecaudadoras();
  },
  methods: {
    async cargarTipoAseo() {
      const res = await this.api('listar_tipo_aseo');
      this.tipoAseo = res.data || [];
    },
    async cargarRecaudadoras() {
      const res = await this.api('listar_recaudadoras');
      this.recaudadoras = res.data || [];
    },
    async buscarContrato() {
      this.resultados = [];
      this.adeudos = [];
      this.contrato = null;
      this.convenio = null;
      const res = await this.api('buscar_contrato', {
        num_contrato: this.form.num_contrato,
        ctrol_aseo: this.form.ctrol_aseo
      });
      if (res.data && res.data.length) {
        this.contrato = res.data[0];
        // Buscar convenio si aplica
        const conv = await this.api('buscar_convenio', { idlc: this.contrato.control_contrato });
        if (conv.data && conv.data.length) this.convenio = conv.data[0];
        // Buscar adeudos
        const adeu = await this.api('listar_adeudos', { control_contrato: this.contrato.control_contrato });
        this.adeudos = (adeu.data || []).map(row => ({ ...row, selected: false }));
      } else {
        alert('No existe contrato con ese dato, intenta con otro');
      }
    },
    async ejecutarOpcion() {
      const seleccionados = this.adeudos.filter(r => r.selected);
      if (!seleccionados.length) {
        alert('Seleccione al menos un adeudo');
        return;
      }
      const rows = seleccionados.map(r => ({
        control_contrato: r.expression,
        periodo: r.expression_1,
        ctrol_oper: r.expression_3
      }));
      const res = await this.api('ejecutar_opcion', {
        rows,
        opcion: this.form.opcion,
        fecha: this.form.fecha,
        reca: this.form.reca,
        caja: this.form.caja,
        operacion: this.form.operacion,
        folio_rcbo: this.form.folio_rcbo,
        obs: this.form.obs,
        usuario: this.form.usuario
      });
      this.resultados = res.data || [];
      this.buscarContrato(); // refrescar
    },
    async api(action, params = {}) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, ...params } })
      });
      return (await res.json()).eResponse;
    }
  }
};
</script>

<style scoped>
.adeudos-opc-mult { max-width: 900px; margin: 0 auto; }
.form-row { margin-bottom: 1em; }
.table { width: 100%; border-collapse: collapse; }
.table th, .table td { border: 1px solid #ccc; padding: 0.5em; }
</style>
